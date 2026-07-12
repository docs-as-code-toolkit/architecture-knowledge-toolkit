// Behaviour specification for the generic agent adapter generator template
// (templates/scripts/build-agent-adapters.js) that consuming projects copy.
//
// It must produce project-correct adapters without being edited: derive the
// project name (env, config, or directory), name the Cursor rule after the
// project, auto-detect whether to list local skills or route to the toolkit, and
// never claim "no local skills" when skills exist.

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const templateScripts = path.join(repoRoot, "templates", "scripts");

function makeProject(t, dirName = "demo-project") {
  const parent = fs.mkdtempSync(path.join(os.tmpdir(), "akt-template-"));
  t.after(() => fs.rmSync(parent, { recursive: true, force: true }));
  const project = path.join(parent, dirName);
  fs.mkdirSync(project, { recursive: true });
  fs.cpSync(templateScripts, path.join(project, "scripts"), { recursive: true });
  return project;
}

function run(project, { args = [], env = {} } = {}) {
  return spawnSync(
    process.execPath,
    [path.join(project, "scripts/build-agent-adapters.js"), ...args],
    { encoding: "utf8", env: { ...process.env, ...env } },
  );
}

function writeSkill(project, name) {
  const dir = path.join(project, "skills", name);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "SKILL.md"), `---\nname: ${name}\ndescription: A local skill.\n---\n\n# ${name}\n`);
}

test("Toolkit-routing mode: no skills yields project-named adapters that route to the toolkit", (t) => {
  // Given: a consuming project with no local skills and an explicit project name
  const project = makeProject(t);

  // When: the generator runs
  const result = run(project, { env: { AGENT_ADAPTER_PROJECT: "acme-service" } });

  // Then: it writes all four adapters, names the Cursor rule after the project,
  // routes to the toolkit, and does not list local skills
  assert.equal(result.status, 0, result.stderr);
  for (const adapter of [
    "adapters/codex/AGENTS.md",
    "adapters/vibe/AGENTS.md",
    "adapters/github-copilot/copilot-instructions.md",
    "adapters/cursor/rules/acme-service.mdc",
  ]) {
    assert.ok(fs.existsSync(path.join(project, adapter)), `expected ${adapter}`);
  }
  const codex = fs.readFileSync(path.join(project, "adapters/codex/AGENTS.md"), "utf8");
  assert.match(codex, /acme-service repository/);
  assert.match(codex, /architecture-knowledge-toolkit/);
  assert.doesNotMatch(codex, /## Local Skills/);
  // It must not be wired to the toolkit's own name or Cursor file.
  assert.ok(!fs.existsSync(path.join(project, "adapters/cursor/rules/architecture-knowledge-toolkit.mdc")));
});

test("Skills mode: local skills are listed and the no-skills claim is not rendered", (t) => {
  // Given: a consuming project that has local skills
  const project = makeProject(t);
  writeSkill(project, "write-thing");

  // When: the generator runs
  const result = run(project, { env: { AGENT_ADAPTER_PROJECT: "acme-service" } });

  // Then: the adapter lists the skill and never claims there are no local skills
  assert.equal(result.status, 0, result.stderr);
  const codex = fs.readFileSync(path.join(project, "adapters/codex/AGENTS.md"), "utf8");
  assert.match(codex, /## Local Skills/);
  assert.match(codex, /`write-thing`: `skills\/write-thing\/SKILL\.md`/);
  assert.doesNotMatch(codex, /keeps no local agent skills/);
});

test("Project name falls back to the config file, then the directory name", (t) => {
  // Given: a project with no env override but a config file
  const project = makeProject(t, "outer-dir");
  fs.mkdirSync(path.join(project, "adapters"), { recursive: true });
  fs.writeFileSync(
    path.join(project, "adapters/agent-adapters.config.json"),
    JSON.stringify({ project: "configured-name" }),
  );

  // When: the generator runs without AGENT_ADAPTER_PROJECT
  const result = run(project, { env: { AGENT_ADAPTER_PROJECT: "" } });

  // Then: the config name wins over the directory name
  assert.equal(result.status, 0, result.stderr);
  assert.ok(fs.existsSync(path.join(project, "adapters/cursor/rules/configured-name.mdc")));

  // And when the config is removed, the directory name is used
  fs.rmSync(path.join(project, "adapters/agent-adapters.config.json"));
  fs.rmSync(path.join(project, "adapters/cursor"), { recursive: true, force: true });
  const result2 = run(project, { env: { AGENT_ADAPTER_PROJECT: "" } });
  assert.equal(result2.status, 0, result2.stderr);
  assert.ok(fs.existsSync(path.join(project, "adapters/cursor/rules/outer-dir.mdc")));
});

test("Check mode reports current and detects drift", (t) => {
  // Given: a project whose adapters were just generated
  const project = makeProject(t);
  run(project, { env: { AGENT_ADAPTER_PROJECT: "acme-service" } });

  // When/Then: check passes on a clean tree
  const clean = run(project, { args: ["--check"], env: { AGENT_ADAPTER_PROJECT: "acme-service" } });
  assert.equal(clean.status, 0, clean.stderr);
  assert.match(clean.stdout, /Generated agent adapters are current\./);

  // When/Then: a hand edit is detected as stale
  fs.appendFileSync(path.join(project, "adapters/codex/AGENTS.md"), "\ndrift\n");
  const stale = run(project, { args: ["--check"], env: { AGENT_ADAPTER_PROJECT: "acme-service" } });
  assert.equal(stale.status, 1);
  assert.match(stale.stderr, /stale/);
});
