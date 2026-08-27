// Behaviour specification for adapters/shared/install-skills.sh, the cross-engine
// helper that symlinks the toolkit's exposed skills into a SKILL.md discovery root.
//
// The installer performs non-trivial filesystem operations, so it is exercised
// here against throwaway workspaces rather than the real project tree.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const installer = path.join(repoRoot, "adapters/shared/install-skills.sh");

function workspace(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "skill-installer-"));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function run(root, ...args) {
  return spawnSync(
    "bash",
    [installer, ...args, "--root", root],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        ARCHITECTURE_KNOWLEDGE_TOOLKIT: repoRoot,
      },
    },
  );
}

test("installs exposed skills and skips helper skills", (t) => {
  const root = workspace(t);

  const result = run(root);

  assert.equal(result.status, 0, result.stderr);
  assert.equal(fs.lstatSync(path.join(root, "adr")).isSymbolicLink(), true);
  assert.equal(fs.existsSync(path.join(root, "grilling")), false);
});

test("install is idempotent across repeated runs", (t) => {
  const root = workspace(t);

  const first = run(root);
  assert.equal(first.status, 0, first.stderr);
  const second = run(root);
  assert.equal(second.status, 0, second.stderr);

  // Re-running re-links but never nests a symlink inside itself.
  assert.equal(fs.lstatSync(path.join(root, "adr")).isSymbolicLink(), true);
  assert.equal(
    fs.realpathSync(path.join(root, "adr")),
    path.join(repoRoot, "skills", "adr"),
  );
});

test("does not modify an existing project-owned skill directory", (t) => {
  const root = workspace(t);
  const customSkill = path.join(root, "adr");
  fs.mkdirSync(customSkill, { recursive: true });
  fs.writeFileSync(path.join(customSkill, "SKILL.md"), "# Project ADR skill\n");

  const result = run(root);

  assert.equal(result.status, 0, result.stderr);
  assert.equal(fs.lstatSync(customSkill).isDirectory(), true);
  assert.equal(
    fs.readFileSync(path.join(customSkill, "SKILL.md"), "utf8"),
    "# Project ADR skill\n",
  );
  assert.equal(fs.existsSync(path.join(customSkill, "adr")), false);
});

test("remove deletes toolkit links but preserves project-owned skills", (t) => {
  const root = workspace(t);
  const customSkill = path.join(root, "custom");
  fs.mkdirSync(customSkill, { recursive: true });
  fs.writeFileSync(path.join(customSkill, "SKILL.md"), "# Custom\n");

  assert.equal(run(root).status, 0);
  const result = run(root, "remove");

  assert.equal(result.status, 0, result.stderr);
  assert.equal(fs.existsSync(path.join(root, "adr")), false);
  assert.equal(fs.existsSync(path.join(customSkill, "SKILL.md")), true);
});