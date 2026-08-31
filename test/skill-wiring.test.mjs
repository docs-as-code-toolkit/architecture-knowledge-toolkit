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

test("The Convergence Check result states live in exactly one skill", () => {
  // Given the canonical skills under skills/
  // When they are searched for the gate's result vocabulary
  //
  // Naming a result state is allowed and often clearer: implement-issue-workflow
  // says which results stop integration, which is its own policy expressed in
  // the gate's vocabulary. What must not spread is the *definition* — the table
  // row that says what a state means. That is the copy which drifts.
  const carriers = skillsContaining(
    /^\|\s*\*\*Converged with recorded waivers\*\*\s*\|/im,
  );

  // Then only the Convergence Check itself defines it
  assert.deepEqual(carriers, [rel(canonical)]);
});

test("The Convergence Check questions are not copied into a caller", () => {
  // Given the canonical skills under skills/
  // When they are searched for the gate's seven-question structure
  const carriers = skillsContaining(/Every question must be able to fail/i);

  // Then only the Convergence Check itself carries it
  assert.deepEqual(carriers, [rel(canonical)]);
});
