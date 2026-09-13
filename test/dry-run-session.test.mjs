// Behaviour specification for adapters/shared/dry-run-session.sh, the helper that
// runs an agent session on a clone of a repository that cannot publish anything.
//
// The tests are hermetic: every repository is a throwaway directory, no probe
// needs the network, and the sandbox runtime is replaced by a stand-in that
// records the policy it is given and runs the command unsandboxed. The tests
// therefore specify the policy, not its enforcement. The helper's `check`
// subcommand is the live counterpart on a user's machine — it attempts every
// write path inside a real sandbox — and is not exercised here.
//
// Bridged from: features/dry-run-session.feature

import { after, test } from "node:test";
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
const helper = path.join(repoRoot, "adapters/shared/dry-run-session.sh");

// Git runs without the developer's global and system configuration. A global
// excludes file that ignores .claude/settings.local.json — a common setup for
// Claude Code users — would otherwise keep that file out of the source
// repository one scenario commits it to, and the test would depend on the
// machine it runs on.
// Stands in for srt: records the policy passed with --settings to the file named
// by DRY_RUN_STUB_POLICY, then runs the command after -- without a sandbox.
const stubDir = fs.mkdtempSync(path.join(os.tmpdir(), "dry-run-session-srt-"));
after(() => fs.rmSync(stubDir, { recursive: true, force: true }));
const stubSrt = path.join(stubDir, "srt");
fs.writeFileSync(
  stubSrt,
  [
    "#!/bin/sh",
    '[ "$1" = "--settings" ] || { echo "stub srt: expected --settings" >&2; exit 97; }',
    '[ -z "$DRY_RUN_STUB_POLICY" ] || cp "$2" "$DRY_RUN_STUB_POLICY"',
    // Without --, srt would read a command's own options, such as claude -c, as its own.
    '[ "$3" = "--" ] || { echo "stub srt: expected -- before the command" >&2; exit 98; }',
    "shift 3",
    'exec "$@"',
    "",
  ].join("\n"),
  { mode: 0o755 },
);

const hermetic = {
  DRY_RUN_SESSION_SRT: stubSrt,
  GIT_AUTHOR_NAME: "Dry Run",
  GIT_AUTHOR_EMAIL: "dry-run@example.invalid",
  GIT_COMMITTER_NAME: "Dry Run",
  GIT_COMMITTER_EMAIL: "dry-run@example.invalid",
  GIT_CONFIG_GLOBAL: "/dev/null",
  GIT_CONFIG_NOSYSTEM: "1",
};

function workspace(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "dry-run-session-"));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return dir;
}

function git(cwd, ...args) {
  const result = spawnSync("git", ["-c", "core.excludesFile=/dev/null", ...args], {
    cwd,
    encoding: "utf8",
    env: { ...process.env, ...hermetic },
  });
  if (result.status !== 0) {
    throw new Error(`git ${args.join(" ")} failed: ${result.stderr}`);
  }
  return result.stdout.trim();
}

// A source repository with one commit and a remote, so a test can tell whether
// setting up a dry run touched it.
function sourceRepository(dir, files = { "README.md": "source\n" }) {
  const src = path.join(dir, "source");
  fs.mkdirSync(src);
  git(src, "init", "--quiet", "-b", "main");
  for (const [name, content] of Object.entries(files)) {
    fs.mkdirSync(path.dirname(path.join(src, name)), { recursive: true });
    fs.writeFileSync(path.join(src, name), content);
  }
  git(src, "add", "-A");
  git(src, "commit", "--quiet", "-m", "initial");
  git(src, "remote", "add", "origin", "https://example.invalid/source.git");
  return src;
}

function run(args, env = {}) {
  const merged = { ...process.env, ...hermetic, ...env };
  if (!("DRY_RUN_ALLOWED_DOMAINS" in env)) delete merged.DRY_RUN_ALLOWED_DOMAINS;
  return spawnSync("bash", [helper, ...args], {
    cwd: repoRoot,
    encoding: "utf8",
    env: merged,
  });
}

// Runs a command in the session and returns the result with the recorded policy.
function inSession(t, clone, command, env = {}) {
  const record = path.join(workspace(t), "policy.json");
  const result = run(["start", clone, "--", ...command], { ...env, DRY_RUN_STUB_POLICY: record });
  assert.equal(result.status, 0, result.stderr);
  return { result, policy: JSON.parse(fs.readFileSync(record, "utf8")) };
}

function dryRunClone(t, files) {
  const dir = workspace(t);
  const src = sourceRepository(dir, files);
  const clone = path.join(dir, "clone");
  const result = run(["setup", src, clone]);
  assert.equal(result.status, 0, result.stderr);
  return { dir, src, clone, result };
}

test("Setting up clones into a directory of its own", (t) => {
  // Given: a source repository with a remote
  const dir = workspace(t);
  const src = sourceRepository(dir);
  const pushUrlBefore = git(src, "remote", "get-url", "--push", "origin");

  // When: a dry-run clone is set up from it
  const clone = path.join(dir, "clone");
  const result = run(["setup", src, clone]);

  // Then: the clone exists and the source's push URL and hooks are unchanged
  assert.equal(result.status, 0, result.stderr);
  assert.ok(fs.existsSync(path.join(clone, ".git")));
  assert.ok(fs.existsSync(path.join(clone, "README.md")));
  assert.equal(git(src, "remote", "get-url", "--push", "origin"), pushUrlBefore);
  assert.equal(
    spawnSync("git", ["config", "--get", "core.hooksPath"], { cwd: src }).status,
    1,
  );
});

test("The session runs inside the sandbox runtime", (t) => {
  // Given: a dry-run clone
  const { clone } = dryRunClone(t);
  const real = fs.realpathSync(clone);

  // When: a command runs in the session
  const { result, policy } = inSession(t, clone, ["pwd", "-P"]);

  // Then: it runs in the clone through the sandbox runtime, whose policy allows writes only to the clone and the agent's own state and reaches only the agent's API
  assert.equal(result.stdout.trim(), real);
  // Besides the clone: /tmp/claude, /tmp/claude-<uid> and /tmp/claude-* (also under
  // /private), ~/.claude and ~/.claude.json.
  const agentState = /^(?:(?:\/private)?\/tmp\/claude(?:-(?:\d+|\*))?|~\/\.claude(?:\.json(?:\.\*)?)?)$/;
  assert.ok(policy.filesystem.allowWrite.includes(real));
  for (const entry of policy.filesystem.allowWrite) {
    assert.ok(entry === real || agentState.test(entry), `unexpected writable path ${entry}`);
  }
  assert.deepEqual(policy.network.allowedDomains, ["api.anthropic.com", "*.anthropic.com", "claude.ai"]);
});

test("GitHub and GitLab stay denied when every domain is allowed", (t) => {
  // Given: a dry-run clone and an allowlist opened to every domain
  const { clone } = dryRunClone(t);

  // When: a command runs in the session
  const { policy } = inSession(t, clone, ["true"], { DRY_RUN_ALLOWED_DOMAINS: "*" });

  // Then: the sandbox policy still denies GitHub and GitLab
  assert.deepEqual(policy.network.allowedDomains, ["*"]);
  for (const domain of ["github.com", "*.github.com", "gitlab.com", "*.gitlab.com"]) {
    assert.ok(policy.network.deniedDomains.includes(domain), `${domain} is not denied`);
  }
});

test("Credentials and the clone's guards are out of the session's reach", (t) => {
  // Given: a dry-run clone
  const { clone } = dryRunClone(t);
  const real = fs.realpathSync(clone);

  // When: a command runs in the session
  const { policy } = inSession(t, clone, ["true"]);

  // Then: the sandbox policy denies reading SSH keys and gh, glab and git credential files, and writing the hook, the deny rules and the agent's settings
  for (const entry of ["~/.ssh", "~/.config/gh", "~/.config/glab-cli", "~/.netrc", "~/.git-credentials"]) {
    assert.ok(policy.filesystem.denyRead.includes(entry), `${entry} stays readable`);
  }
  for (const entry of [
    `${real}/.git/dry-run-hooks`,
    `${real}/.claude/settings.local.json`,
    "~/.claude/settings.json",
    "~/.claude/hooks",
  ]) {
    assert.ok(policy.filesystem.denyWrite.includes(entry), `${entry} stays writable`);
  }
});

test("Without the sandbox runtime no session starts", (t) => {
  // Given: a dry-run clone and no sandbox runtime
  const { dir, clone } = dryRunClone(t);
  const marker = path.join(dir, "ran");

  // When: the session is started
  const result = run(["start", clone, "--", "touch", marker], {
    DRY_RUN_SESSION_SRT: path.join(dir, "no-such-srt"),
  });

  // Then: it fails, names the missing runtime and runs nothing
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /sandbox runtime/);
  assert.ok(!fs.existsSync(marker), "the command ran without a sandbox");
});

test("A push to the clone's own remote is refused", (t) => {
  // Given: a dry-run clone
  const { clone } = dryRunClone(t);

  // When: the session pushes to origin
  const result = run(["start", clone, "--", "git", "push", "origin", "HEAD"]);

  // Then: the push fails because the push URL is unusable
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /PUSH-DISABLED-dry-run-session/);
});

test("A push to an explicitly named repository is rejected by the hook", (t) => {
  // Given: a dry-run clone and an empty bare repository
  const { dir, clone } = dryRunClone(t);
  const bare = path.join(dir, "target.git");
  git(dir, "init", "--quiet", "--bare", bare);

  // When: the session pushes to that repository by path
  const result = run(["start", clone, "--", "git", "push", bare, "HEAD:refs/heads/probe"]);

  // Then: the pre-push hook rejects it and the repository receives no refs
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /dry-run-session: pushing is disabled in this clone/);
  assert.equal(git(bare, "for-each-ref"), "");
});

test("A push over SSH never reaches a remote", (t) => {
  // Given: a dry-run clone
  const { clone } = dryRunClone(t);

  // When: the session pushes to an SSH URL, bypassing hooks
  const result = run([
    "start", clone, "--",
    "git", "push", "--no-verify", "ssh://git@example.invalid/probe.git", "HEAD",
  ]);

  // Then: the push fails before a connection is made
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Could not read from remote repository/);
  assert.doesNotMatch(result.stderr, /Repository not found/);
});

test("The session carries no credentials", (t) => {
  // Given: tokens and an SSH agent socket in the calling environment
  const { clone } = dryRunClone(t);
  const outside = {
    GH_TOKEN: "outside-token",
    GITHUB_TOKEN: "outside-token",
    GITLAB_TOKEN: "outside-token",
    SSH_AUTH_SOCK: path.join(os.tmpdir(), "outside-agent.sock"),
  };

  // When: a command runs inside the session
  const env = run(["start", clone, "--", "env"], outside);
  const helpers = run(["start", clone, "--", "git", "config", "--get-all", "credential.helper"], outside);

  // Then: it sees no token, no agent socket, no usable SSH, no credential helper and no terminal prompt
  assert.equal(env.status, 0, env.stderr);
  const seen = Object.fromEntries(
    env.stdout
      .split("\n")
      .filter((line) => line.includes("="))
      .map((line) => [line.slice(0, line.indexOf("=")), line.slice(line.indexOf("=") + 1)]),
  );
  for (const name of ["GH_TOKEN", "GITHUB_TOKEN", "GITLAB_TOKEN", "SSH_AUTH_SOCK"]) {
    assert.equal(seen[name], undefined, `${name} leaked into the session`);
  }
  assert.equal(seen.GIT_SSH_COMMAND, "false");
  assert.equal(seen.GIT_TERMINAL_PROMPT, "0");
  assert.ok(!fs.existsSync(seen.GH_CONFIG_DIR) || fs.readdirSync(seen.GH_CONFIG_DIR).length === 0);
  const configured = helpers.stdout.replace(/\n$/, "").split("\n");
  assert.equal(configured.at(-1), "", "a credential helper is still active");
});

test("Claude Code is denied the commands that publish", (t) => {
  // Given: a dry-run clone
  const { clone } = dryRunClone(t);

  // When: its local Claude Code settings are read
  const settings = JSON.parse(
    fs.readFileSync(path.join(clone, ".claude/settings.local.json"), "utf8"),
  );

  // Then: they deny git push, gh issue, gh pr, gh api and glab
  const deny = settings.permissions.deny;
  for (const rule of ["Bash(git push *)", "Bash(gh issue *)", "Bash(gh pr *)", "Bash(gh api *)", "Bash(glab *)"]) {
    assert.ok(deny.includes(rule), `missing deny rule ${rule}`);
  }
});

test("A local settings file the project already has is left untouched", (t) => {
  // Given: a source repository that already contains .claude/settings.local.json
  const own = '{ "permissions": { "allow": ["Read"] } }\n';

  // When: a dry-run clone is set up from it
  const { clone, result } = dryRunClone(t, {
    "README.md": "source\n",
    ".claude/settings.local.json": own,
  });

  // Then: the file is not changed and the setup says so
  assert.equal(fs.readFileSync(path.join(clone, ".claude/settings.local.json"), "utf8"), own);
  assert.match(result.stderr, /left untouched/);
});

test("A target that already exists is refused", (t) => {
  // Given: a directory already exists at the target path
  const dir = workspace(t);
  const src = sourceRepository(dir);
  const target = path.join(dir, "taken");
  fs.mkdirSync(target);
  fs.writeFileSync(path.join(target, "keep.txt"), "keep\n");

  // When: a dry-run clone is set up into it
  const result = run(["setup", src, target]);

  // Then: the setup fails and the directory is left as it was
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /already exists/);
  assert.deepEqual(fs.readdirSync(target), ["keep.txt"]);
});
