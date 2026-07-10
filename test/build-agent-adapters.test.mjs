// Behaviour specification bridge for the agent adapter generator.
//
// Living documentation: features/agent-adapter-generation.feature. node:test is
// a classic test runner, not a native BDD framework, so each Gherkin scenario is
// bridged to a test whose name is the sanitized scenario title, with Given/When/
// Then comment anchors separating Arrange, Act, and Assert.
//
// Each test runs against an isolated copy of scripts/, skills/, and adapters/ in
// a temporary workspace so the real repository tree is never modified.

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const ADAPTERS = [
  "adapters/codex/AGENTS.md",
  "adapters/vibe/AGENTS.md",
  "adapters/github-copilot/copilot-instructions.md",
  "adapters/cursor/rules/architecture-knowledge-toolkit.mdc",
];

function makeWorkspace(t) {
  const workspace = fs.mkdtempSync(path.join(os.tmpdir(), "akt-adapters-"));
  t.after(() => fs.rmSync(workspace, { recursive: true, force: true }));
  for (const dir of ["scripts", "skills", "adapters"]) {
    fs.cpSync(path.join(repoRoot, dir), path.join(workspace, dir), { recursive: true });
  }
  return workspace;
}

function runGenerator(workspace, args = []) {
  return spawnSync(
    process.execPath,
    [path.join(workspace, "scripts/build-agent-adapters.js"), ...args],
    { encoding: "utf8" },
  );
}

function writeSkill(workspace, name, frontMatter) {
  const dir = path.join(workspace, "skills", name);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(
    path.join(dir, "SKILL.md"),
    `---\n${frontMatter}\n---\n\n# ${name}\n`,
  );
}

test("Build regenerates all four adapters", (t) => {
  // Given: a repository with canonical skills and no generated adapters
  const workspace = makeWorkspace(t);
  fs.rmSync(path.join(workspace, "adapters"), { recursive: true, force: true });

  // When: the adapter generator runs
  const result = runGenerator(workspace);

  // Then: it writes the codex, vibe, github-copilot, and cursor adapters with
  // the generated-file notice
  assert.equal(result.status, 0, result.stderr);
  for (const adapter of ADAPTERS) {
    const adapterPath = path.join(workspace, adapter);
    assert.ok(fs.existsSync(adapterPath), `expected ${adapter} to be written`);
    assert.match(fs.readFileSync(adapterPath, "utf8"), /GENERATED FILE: edit skills/);
  }
});

test("Check reports adapters are current on a clean tree", (t) => {
  // Given: a repository whose adapters were just generated
  const workspace = makeWorkspace(t);
  runGenerator(workspace);

  // When: the adapter generator runs in check mode
  const result = runGenerator(workspace, ["--check"]);

  // Then: it exits successfully and reports that the adapters are current
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Generated agent adapters are current\./);
});

test("Check detects a stale adapter", (t) => {
  // Given: a repository whose generated adapter was edited by hand
  const workspace = makeWorkspace(t);
  runGenerator(workspace);
  const codex = path.join(workspace, "adapters/codex/AGENTS.md");
  fs.appendFileSync(codex, "\nhand-edited drift\n");

  // When: the adapter generator runs in check mode
  const result = runGenerator(workspace, ["--check"]);

  // Then: it exits with a failure and names the stale adapter
  assert.equal(result.status, 1);
  assert.match(result.stderr, /stale/);
  assert.match(result.stderr, /adapters\/codex\/AGENTS\.md/);
});

test("Skills marked adapter_expose false are not listed", (t) => {
  // Given: a skill whose front matter sets adapter_expose to false and a normal skill
  const workspace = makeWorkspace(t);
  writeSkill(workspace, "zz-shown-skill", "name: zz-shown-skill\ndescription: A visible skill.");
  writeSkill(
    workspace,
    "zz-hidden-skill",
    "name: zz-hidden-skill\ndescription: A hidden skill.\nadapter_expose: false",
  );

  // When: the adapter generator runs
  const result = runGenerator(workspace);

  // Then: the generated adapters list the normal skill and omit the hidden skill
  assert.equal(result.status, 0, result.stderr);
  const codex = fs.readFileSync(path.join(workspace, "adapters/codex/AGENTS.md"), "utf8");
  assert.match(codex, /zz-shown-skill/);
  assert.doesNotMatch(codex, /zz-hidden-skill/);
});
