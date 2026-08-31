// Behaviour specification for the wiring between canonical skills.
//
// Skills are prose contracts. Whether an agent obeys one is not verifiable from
// this repository — that is the conformance and evaluation layer tracked in #65.
// What is verifiable, and what breaks silently without a guard, is the wiring
// underneath: a skill that defers a rule must still point at the file that owns
// it, and a rule that was deferred must not have been copied back.
//
// Both checks fail on a real regression: deleting a reference, renaming a skill
// directory, or pasting the canonical rules into a caller.
//
// Bridged from: features/skill-wiring.feature

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const skillsDir = path.join(repoRoot, "skills");

// Every SKILL.md in the tree, at any nesting depth.
function skillFiles(dir = skillsDir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return skillFiles(full);
    return entry.name === "SKILL.md" ? [full] : [];
  });
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function rel(file) {
  return path.relative(repoRoot, file);
}

// Relative references to other skills, as they are written in the prose:
// `../<something>/SKILL.md` inside backticks.
function skillReferences(file) {
  const text = read(file);
  const matches = text.match(/`(\.\.\/[A-Za-z0-9_./-]*SKILL\.md)`/g) || [];
  return matches.map((m) => m.slice(1, -1));
}

test("Every skill-to-skill reference resolves", () => {
  // Given the canonical skills under skills/
  const files = skillFiles();
  assert.ok(files.length > 0, "no skills found");

  // When their relative references to other SKILL.md files are resolved
  const broken = [];
  let checked = 0;
  for (const file of files) {
    for (const reference of skillReferences(file)) {
      checked += 1;
      const target = path.resolve(path.dirname(file), reference);
      if (!fs.existsSync(target)) broken.push(`${rel(file)} -> ${reference}`);
    }
  }

  // Then every referenced file exists
  assert.ok(checked > 0, "no skill-to-skill references found to check");
  assert.deepEqual(broken, []);
});

test("The skills that own a gate moment reach the Convergence Check", () => {
  // Given architecture-impact, implement-issue-workflow and pr-review
  const callers = ["architecture-impact", "implement-issue-workflow", "pr-review"];

  // When each is inspected for the canonical gate
  const missing = callers.filter((name) => {
    const file = path.join(skillsDir, name, "SKILL.md");
    return !skillReferences(file).includes("../convergence-check/SKILL.md");
  });

  // Then all three reference skills/convergence-check/SKILL.md
  assert.deepEqual(missing, []);
});

// The gate's own rule, applied to the gate: a second copy of a rule inside a
// caller is exactly the drift the gate exists to detect. These two tests are
// what stops that copy from being made quietly.
const canonical = path.join(skillsDir, "convergence-check", "SKILL.md");

function skillsContaining(pattern) {
  return skillFiles()
    .filter((file) => pattern.test(read(file)))
    .map(rel);
}

// Both checks read the canonical file for what to look for, rather than
// hard-coding it. Rename a result state or a question and the guard follows;
// hard-coded copies would quietly stop guarding anything.
function canonicalResultStates() {
  const section = read(canonical).split("## Result")[1].split("###")[0];
  return [...section.matchAll(/^\|\s*\*\*([^*]+)\*\*\s*\|/gim)].map((m) =>
    m[1].trim(),
  );
}

function canonicalQuestionTitles() {
  const section = read(canonical)
    .split("## The seven questions")[1]
    .split("\n## ")[0];
  return [...section.matchAll(/^###\s+\d+\.\s+(.+?)\s*$/gim)].map((m) => m[1]);
}

function escapeForRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

test("The Convergence Check result states live in exactly one skill", () => {
  // Given the canonical skills under skills/, and the four result states read
  // from the Convergence Check itself
  const states = canonicalResultStates();
  assert.equal(states.length, 4, `expected four result states, got ${states.join(", ")}`);

  // When they are searched for a definition of any of those states
  //
  // Naming a state elsewhere is allowed and often clearer: implement-issue-workflow
  // says which results stop integration, which is its own policy expressed in the
  // gate's vocabulary. What must not spread is the *definition* — the table row
  // saying what a state means. That is the copy that drifts.
  const offenders = states.flatMap((state) => {
    const row = new RegExp(`^\\|\\s*\\*\\*${escapeForRegex(state)}\\*\\*\\s*\\|`, "im");
    return skillsContaining(row)
      .filter((file) => file !== rel(canonical))
      .map((file) => `${file} defines "${state}"`);
  });

  // Then only the Convergence Check itself defines them
  assert.deepEqual(offenders, []);
});

test("The Convergence Check questions are not copied into a caller", () => {
  // Given the canonical skills under skills/, and the seven question titles read
  // from the Convergence Check itself
  const titles = canonicalQuestionTitles();
  assert.equal(titles.length, 7, `expected seven questions, got ${titles.length}`);

  // When every other skill is searched for those titles as headings
  //
  // A caller could copy the questions without the section heading above them,
  // so the heading alone is not what is checked. Two or more of the canonical
  // titles appearing as headings in one file is the copy; a single shared word
  // such as "Traceability" is not.
  const offenders = skillFiles()
    .filter((file) => file !== canonical)
    .map((file) => {
      const text = read(file);
      const hits = titles.filter((title) =>
        new RegExp(`^#+\\s+(\\d+\\.\\s+)?${escapeForRegex(title)}\\s*$`, "im").test(text),
      );
      return { file: rel(file), hits };
    })
    .filter((entry) => entry.hits.length >= 2)
    .map((entry) => `${entry.file} carries ${entry.hits.length} question headings`);

  // Then only the Convergence Check itself carries the structure
  assert.deepEqual(offenders, []);
  // ... and the canonical file still has all seven, so the guard has something
  // to compare against.
  const canonicalHits = titles.filter((title) =>
    new RegExp(`^###\\s+\\d+\\.\\s+${escapeForRegex(title)}\\s*$`, "im").test(read(canonical)),
  );
  assert.equal(canonicalHits.length, 7);
});
