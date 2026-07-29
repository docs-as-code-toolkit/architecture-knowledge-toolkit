// Behaviour specification for the generic docs-toolbox task runner template
// (templates/scripts/build.sh) that consuming projects copy to their root.
//
// The runner carries shell, container, and argument-forwarding logic but is only
// documented, not exercised, elsewhere. These tests check that it is at least
// syntactically valid and that its local-mode dispatch invokes the expected
// vendored tool for each task, using stub `ruby`/`node` on PATH.

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const templateBuildSh = path.join(repoRoot, "templates", "scripts", "build.sh");

test("template build.sh is valid POSIX shell (sh -n)", () => {
  const result = spawnSync("sh", ["-n", templateBuildSh], { encoding: "utf8" });
  assert.equal(result.status, 0, result.stderr);
});

// Set up a throwaway consuming project with build.sh at its root and stub
// `ruby`/`node` executables that record their arguments, then run a task in
// local mode and return what the stubs saw.
function runTaskWithStubs(t, task) {
  const parent = fs.mkdtempSync(path.join(os.tmpdir(), "akt-buildsh-"));
  t.after(() => fs.rmSync(parent, { recursive: true, force: true }));

  fs.copyFileSync(templateBuildSh, path.join(parent, "build.sh"));
  fs.mkdirSync(path.join(parent, "scripts"), { recursive: true });

  const binDir = path.join(parent, "stub-bin");
  fs.mkdirSync(binDir);
  const log = path.join(parent, "invocations.log");
  for (const tool of ["ruby", "node", "asciidoctor"]) {
    const stub = path.join(binDir, tool);
    fs.writeFileSync(stub, `#!/bin/sh\necho "${tool} $*" >> "$STUB_LOG"\n`);
    fs.chmodSync(stub, 0o755);
  }

  const result = spawnSync("sh", ["build.sh", task], {
    cwd: parent,
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${binDir}:${process.env.PATH}`,
      DOCS_TOOLBOX_LOCAL: "1",
    // eslint-disable-next-line no-undef
      STUB_LOG: log,
    },
  });

  const invocations = fs.existsSync(log) ? fs.readFileSync(log, "utf8") : "";
  return { result, invocations };
}

test("local-mode validate runs the metamodel validator", (t) => {
  const { result, invocations } = runTaskWithStubs(t, "validate");
  assert.equal(result.status, 0, result.stderr);
  assert.match(invocations, /ruby scripts\/validate-metamodel\.rb/);
});

test("local-mode generate runs the validator with --generate", (t) => {
  const { result, invocations } = runTaskWithStubs(t, "generate");
  assert.equal(result.status, 0, result.stderr);
  assert.match(invocations, /ruby scripts\/validate-metamodel\.rb --generate/);
});

test("local-mode check-adapters runs the adapter checker", (t) => {
  const { result, invocations } = runTaskWithStubs(t, "check-adapters");
  assert.equal(result.status, 0, result.stderr);
  assert.match(invocations, /node scripts\/check-agent-adapters\.js/);
});

// Container-mode engine selection. Both engines are stubbed so nothing is
// actually pulled: each records the command it was given and exits 0, which is
// enough to see which one the runner reached for.
function runContainerTaskWithEngineStubs(t, env) {
  const parent = fs.mkdtempSync(path.join(os.tmpdir(), "akt-buildsh-engine-"));
  t.after(() => fs.rmSync(parent, { recursive: true, force: true }));

  fs.copyFileSync(templateBuildSh, path.join(parent, "build.sh"));

  const binDir = path.join(parent, "stub-bin");
  fs.mkdirSync(binDir);
  const log = path.join(parent, "invocations.log");
  for (const engine of ["podman", "docker"]) {
    const stub = path.join(binDir, engine);
    fs.writeFileSync(stub, `#!/bin/sh\necho "${engine} $1" >> "$STUB_LOG"\n`);
    fs.chmodSync(stub, 0o755);
  }

  const result = spawnSync("sh", ["build.sh", "validate"], {
    cwd: parent,
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${binDir}:${process.env.PATH}`,
      STUB_LOG: log,
      DOCS_TOOLBOX_LOCAL: "",
      ...env,
    },
  });

  return {
    result,
    invocations: fs.existsSync(log) ? fs.readFileSync(log, "utf8") : "",
  };
}

test("container mode prefers podman when nothing is forced", (t) => {
  const { invocations } = runContainerTaskWithEngineStubs(t, {});
  assert.match(invocations, /^podman run$/m);
  assert.doesNotMatch(invocations, /^docker run$/m);
});

test("DOCS_TOOLBOX_ENGINE overrides detection", (t) => {
  // podman is on PATH and its `info` probe succeeds, so detection would pick it.
  // The override has to win anyway -- that is the whole point: `podman info`
  // cannot see an OCI runtime that fails only at container start.
  const { invocations } = runContainerTaskWithEngineStubs(t, {
    DOCS_TOOLBOX_ENGINE: "docker",
  });
  assert.match(invocations, /^docker run$/m);
  assert.doesNotMatch(invocations, /^podman run$/m);
});
