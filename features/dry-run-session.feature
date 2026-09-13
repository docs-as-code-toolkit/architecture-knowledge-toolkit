# Living documentation for adapters/shared/dry-run-session.sh.
# Bridged to: test/dry-run-session.test.mjs (node:test, classic runner, no native
# BDD). Each scenario maps to one test named after the scenario title, with
# Given/When/Then comment anchors inside the test body. Traceability is a
# reviewer-verifiable convention, not a build-enforced link.
#
# The tests are hermetic. They replace the sandbox runtime with a stand-in that
# records the policy it is given and runs the command unsandboxed, so they
# specify the policy, not its enforcement. Enforcement is the job of the helper's
# `check` subcommand, which attempts every write path from inside a real sandbox
# on the machine it runs on and is not exercised here.

Feature: Dry-run session
  As someone running agent skills against a real repository
  I want a session that can read but cannot publish
  So that skills which push branches or create issues can run for real without anything leaving the machine

  Scenario: Setting up clones into a directory of its own
    Given a source repository with a remote
    When a dry-run clone is set up from it
    Then the clone exists and the source's push URL and hooks are unchanged

  Scenario: The session runs inside the sandbox runtime
    Given a dry-run clone
    When a command runs in the session
    Then it runs in the clone through the sandbox runtime, whose policy allows writes only to the clone and the agent's own state and reaches only the agent's API

  Scenario: GitHub and GitLab stay denied when every domain is allowed
    Given a dry-run clone and an allowlist opened to every domain
    When a command runs in the session
    Then the sandbox policy still denies GitHub and GitLab

  Scenario: Credentials and the clone's guards are out of the session's reach
    Given a dry-run clone
    When a command runs in the session
    Then the sandbox policy denies reading SSH keys and gh, glab and git credential files, and writing the hook, the deny rules and the agent's settings

  Scenario: Without the sandbox runtime no session starts
    Given a dry-run clone and no sandbox runtime
    When the session is started
    Then it fails, names the missing runtime and runs nothing

  Scenario: A push to the clone's own remote is refused
    Given a dry-run clone
    When the session pushes to origin
    Then the push fails because the push URL is unusable

  Scenario: A push to an explicitly named repository is rejected by the hook
    Given a dry-run clone and an empty bare repository
    When the session pushes to that repository by path
    Then the pre-push hook rejects it and the repository receives no refs

  Scenario: A push over SSH never reaches a remote
    Given a dry-run clone
    When the session pushes to an SSH URL, bypassing hooks
    Then the push fails before a connection is made

  Scenario: The session carries no credentials
    Given tokens and an SSH agent socket in the calling environment
    When a command runs inside the session
    Then it sees no token, no agent socket, no usable SSH, no credential helper and no terminal prompt

  Scenario: Claude Code is denied the commands that publish
    Given a dry-run clone
    When its local Claude Code settings are read
    Then they deny git push, gh issue, gh pr, gh api and glab

  Scenario: A local settings file the project already has is left untouched
    Given a source repository that already contains .claude/settings.local.json
    When a dry-run clone is set up from it
    Then the file is not changed and the setup says so

  Scenario: A target that already exists is refused
    Given a directory already exists at the target path
    When a dry-run clone is set up into it
    Then the setup fails and the directory is left as it was
