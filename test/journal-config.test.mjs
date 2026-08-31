// Behaviour specification for adapters/shared/journal-config.sh, the helper that
// records where a user's private journal lives.
//
// The binding is per user and deliberately stored outside every repository, so
// these tests point the helper at throwaway config files and journal checkouts
// rather than the real one.
//
// Bridged from: features/session-handoff.feature

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
const helper = path.join(repoRoot, "adapters/shared/journal-config.sh");
const installer = path.join(repoRoot, "adapters/shared/install-skills.sh");

function workspace(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "journal-config-"));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

// A journal checkout is any directory holding a clock-in and a clock-out skill;
// the prefixed names exercise the discovery rule.
function journalCheckout(dir, { clockIn = "daily-clock-in", clockOut = "daily-clock-out" } = {}) {
  for (const name of [clockIn, clockOut].filter(Boolean)) {
    const skillDir = path.join(dir, "skills", name);
    fs.mkdirSync(skillDir, { recursive: true });
    fs.writeFileSync(path.join(skillDir, "SKILL.md"), `---\nname: ${name}\n---\n`);
  }
  return dir;
}

function run(configFile, args, env = {}) {
  return spawnSync("bash", [helper, ...args, "--config", configFile], {
    cwd: repoRoot,
    encoding: "utf8",
    env: { ...process.env, ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL: "", ...env },
  });
}

function parse(stdout) {
  return Object.fromEntries(
    stdout
      .split("\n")
      .filter((line) => line.includes("="))
      .map((line) => [line.slice(0, line.indexOf("=")), line.slice(line.indexOf("=") + 1)]),
  );
}

test("An unrecorded binding asks to be set up", (t) => {
  // Given a user with no recorded private journal binding
  const dir = workspace(t);
  const config = path.join(dir, "journal.conf");

  // When the binding is resolved
  const result = run(config, ["get"]);

  // Then it reports that no answer has been recorded yet
  assert.equal(result.status, 3);
});

test("Binding a journal discovers its clock skills", (t) => {
  // Given a journal checkout containing daily-clock-in and daily-clock-out skills
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  const config = path.join(dir, "journal.conf");

  // When the journal is bound to that directory
  assert.equal(run(config, ["set", "--path", journal]).status, 0);

  // Then the resolved binding names the directory and both discovered skills
  const binding = parse(run(config, ["get"]).stdout);
  assert.equal(binding.enabled, "true");
  assert.equal(binding.path, fs.realpathSync(journal));
  assert.equal(binding.clock_in, "skills/daily-clock-in/SKILL.md");
  assert.equal(binding.clock_out, "skills/daily-clock-out/SKILL.md");
});

test("An exact clock-in directory wins over a prefixed one", (t) => {
  // Given a journal checkout holding both `clock-in` and `daily-clock-in`
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  journalCheckout(journal, { clockIn: "clock-in", clockOut: "clock-out" });
  const config = path.join(dir, "journal.conf");

  // When the journal is bound to that directory
  assert.equal(run(config, ["set", "--path", journal]).status, 0);

  // Then the exact name is the one recorded
  const binding = parse(run(config, ["get"]).stdout);
  assert.equal(binding.clock_in, "skills/clock-in/SKILL.md");
  assert.equal(binding.clock_out, "skills/clock-out/SKILL.md");
});

test("Declining a private journal is a stored answer", (t) => {
  // Given a user who keeps no private journal
  const dir = workspace(t);
  const config = path.join(dir, "journal.conf");

  // When that answer is recorded
  assert.equal(run(config, ["disable"]).status, 0);

  // Then the binding resolves as disabled instead of asking again
  const result = run(config, ["get"]);
  assert.equal(result.status, 0);
  assert.equal(parse(result.stdout).enabled, "false");
});

test("The environment overrides the stored binding", (t) => {
  // Given a stored binding to one journal checkout
  const dir = workspace(t);
  const stored = journalCheckout(path.join(dir, "stored"));
  const other = journalCheckout(path.join(dir, "other"));
  const config = path.join(dir, "journal.conf");
  run(config, ["set", "--path", stored]);

  // When the environment names a different journal checkout
  const result = run(config, ["get"], {
    ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL: other,
  });

  // Then the resolved binding names the checkout from the environment
  const binding = parse(result.stdout);
  assert.equal(binding.path, fs.realpathSync(other));
  assert.equal(binding.source, "env");
});

test("The environment can switch the private layer off", (t) => {
  // Given a stored binding to a journal checkout
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  const config = path.join(dir, "journal.conf");
  run(config, ["set", "--path", journal]);

  // When the environment sets the journal to off
  const result = run(config, ["get"], {
    ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL: "off",
  });

  // Then the binding resolves as disabled and the stored binding is untouched
  assert.equal(parse(result.stdout).enabled, "false");
  assert.match(fs.readFileSync(config, "utf8"), /enabled=true/);
});

test("A directory without clock skills is refused", (t) => {
  // Given a directory that contains no clock-in skill
  const dir = workspace(t);
  const empty = path.join(dir, "empty");
  fs.mkdirSync(empty, { recursive: true });
  const config = path.join(dir, "journal.conf");

  // When the journal is bound to that directory
  const result = run(config, ["set", "--path", empty]);

  // Then binding fails and names what is missing
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /no clock-in skill found/);
  assert.equal(fs.existsSync(config), false);
});

test("Binding the toolkit itself is refused", (t) => {
  // Given the toolkit, which ships clock-in and clock-out of its own
  const dir = workspace(t);
  const config = path.join(dir, "journal.conf");

  // When the journal is bound to the toolkit
  const result = run(config, ["set", "--path", repoRoot]);

  // Then binding fails because the journal would delegate to the calling skill
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /resolves into the toolkit/);
  assert.equal(fs.existsSync(config), false);
});

test("A journal whose clock skills are the toolkit's is refused", (t) => {
  // Given a directory whose clock skills are symlinks to the toolkit's own —
  // what `install-skills.sh --skills-dir <dir>/skills` produces.
  const dir = workspace(t);
  const journal = path.join(dir, "journal");
  fs.mkdirSync(path.join(journal, "skills"), { recursive: true });
  for (const name of ["clock-in", "clock-out"]) {
    fs.symlinkSync(path.join(repoRoot, "skills", name), path.join(journal, "skills", name));
  }
  const config = path.join(dir, "journal.conf");

  // When the journal is bound to that directory
  const result = run(config, ["set", "--path", journal]);

  // Then binding fails because the journal would delegate to the calling skill
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /resolves into the toolkit/);
  assert.equal(fs.existsSync(config), false);
});

test("The environment cannot name the toolkit either", (t) => {
  // Given no stored binding
  const dir = workspace(t);
  const config = path.join(dir, "journal.conf");

  // When the environment names the toolkit as the journal
  const result = run(config, ["get"], {
    ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL: repoRoot,
  });

  // Then resolving fails rather than returning a self-delegating binding
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /resolves into the toolkit/);
});

test("Forgetting the binding returns to the setup question", (t) => {
  // Given a stored binding to a journal checkout
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  const config = path.join(dir, "journal.conf");
  run(config, ["set", "--path", journal]);

  // When the binding is forgotten
  assert.equal(run(config, ["forget"]).status, 0);

  // Then it reports that no answer has been recorded yet
  assert.equal(run(config, ["get"]).status, 3);
});

test("A bound journal that is not on this machine is reported, not fatal", (t) => {
  // Given a stored binding whose journal checkout is absent
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  const config = path.join(dir, "journal.conf");
  run(config, ["set", "--path", journal]);
  fs.rmSync(journal, { recursive: true, force: true });

  // When the binding is resolved
  const result = run(config, ["get"]);

  // Then it still reports the binding and warns that the checkout is unreachable
  assert.equal(result.status, 0);
  assert.equal(parse(result.stdout).enabled, "true");
  assert.match(result.stderr, /unreachable/);
});

test("The skill installer records the binding in one step", (t) => {
  // Given a journal checkout and an empty skill discovery root
  const dir = workspace(t);
  const journal = journalCheckout(path.join(dir, "journal"));
  const skillsRoot = path.join(dir, "skills-root");
  fs.mkdirSync(skillsRoot, { recursive: true });
  const configHome = path.join(dir, "config");

  // When the installer runs with the private journal option
  const result = spawnSync(
    "bash",
    [installer, "--skills-dir", skillsRoot, "--private-journal", journal],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        ARCHITECTURE_KNOWLEDGE_TOOLKIT: repoRoot,
        ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL: "",
        XDG_CONFIG_HOME: configHome,
      },
    },
  );

  // Then the skills are linked and the binding resolves to that checkout
  assert.equal(result.status, 0, result.stderr);
  assert.ok(fs.existsSync(path.join(skillsRoot, "clock-in")));
  const config = path.join(configHome, "architecture-knowledge-toolkit/journal.conf");
  assert.equal(parse(run(config, ["get"]).stdout).path, fs.realpathSync(journal));
});

test("The binding is stored outside every repository", (t) => {
  // Given a user configuration home
  const dir = workspace(t);

  // When the binding location is requested
  const result = spawnSync("bash", [helper, "config-path"], {
    cwd: repoRoot,
    encoding: "utf8",
    env: { ...process.env, XDG_CONFIG_HOME: dir },
  });

  // Then it is inside that configuration home and not inside the toolkit
  assert.equal(result.status, 0);
  const location = result.stdout.trim();
  assert.equal(location, path.join(dir, "architecture-knowledge-toolkit/journal.conf"));
  assert.equal(location.startsWith(repoRoot), false);
});
