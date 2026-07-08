#!/usr/bin/env node

async function main() {
  const fs = await import("fs");
  const path = await import("path");
  const scriptDir = path.default.dirname(path.default.resolve(process.argv[1]));
  const root = path.default.resolve(scriptDir, "..");

  const generatedNotice = [
    "<!-- GENERATED FILE: edit skills/**/SKILL.md or scripts/build-agent-adapters.js, then regenerate. -->",
    "",
  ].join("\n");
  const defaultWrap = (body) => `${generatedNotice}${body}`;

  const targets = [
    {
      path: "adapters/codex/AGENTS.md",
      title: "Codex Adapter",
      agent: "Codex",
      wrap: defaultWrap,
    },
    {
      path: "adapters/vibe/AGENTS.md",
      title: "Vibe Adapter",
      agent: "Vibe",
      wrap: defaultWrap,
    },
    {
      path: "adapters/github-copilot/copilot-instructions.md",
      title: "GitHub Copilot Adapter",
      agent: "GitHub Copilot",
      wrap: defaultWrap,
    },
    {
      path: "adapters/cursor/rules/architecture-knowledge-toolkit.mdc",
      title: "Cursor Rule",
      agent: "Cursor",
      wrap: (body) => `---
description: Architecture Knowledge Toolkit adapter
alwaysApply: true
---
${generatedNotice}${body}`,
    },
  ];

  function usage() {
    console.error("Usage: node scripts/build-agent-adapters.js [--check]");
  }

  function listSkillFiles() {
    const skillsDir = path.default.join(root, "skills");
    return fs.default
      .readdirSync(skillsDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => path.default.join("skills", entry.name, "SKILL.md"))
      .filter((skillPath) => fs.default.existsSync(path.default.join(root, skillPath)))
      .sort();
  }

  function parseSkill(skillPath) {
    const text = fs.default.readFileSync(path.default.join(root, skillPath), "utf8");
    const match = text.match(/^---\n([\s\S]*?)\n---\n/);
    const meta = {};

    if (match) {
      for (const line of match[1].split(/\r?\n/)) {
        const field = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
        if (field) {
          meta[field[1]] = field[2].replace(/^["']|["']$/g, "");
        }
      }
    }

    return {
      path: skillPath,
      name: meta.name || path.default.basename(path.default.dirname(skillPath)),
      adapterExpose: meta.adapter_expose !== "false",
    };
  }

  function renderTarget(target, skills) {
    const skillRows = skills
      .map((skill) => `- \`${skill.name}\`: \`${skill.path}\``)
      .join("\n");

    const body = `# ${target.title}

This is a thin ${target.agent}-specific wrapper for the
architecture-knowledge-toolkit. Keep architecture semantics in
repository-root \`general-semantic-contracts.md\` and canonical
\`skills/**/SKILL.md\` files.

When ${target.agent} performs architecture-sensitive work:

1. Read repository-root \`AGENTS.md\`.
2. Read repository-root \`general-semantic-contracts.md\`.
3. Select and read the relevant canonical skill from the list below.
4. Treat this adapter as routing guidance only.

## Canonical Skills

Paths are relative to the architecture-knowledge-toolkit repository root.

${skillRows}

## Adapter Boundary

Do not duplicate ADR, quality scenario, risk, traceability, metadata, or arc42
rules here. Agent-specific files may only wrap, point to, or invoke the
canonical sources.
`;

    return target.wrap(body);
  }

  const args = process.argv.slice(2);
  const check = args.includes("--check");
  const unknown = args.filter((arg) => arg !== "--check");
  if (unknown.length > 0) {
    usage();
    process.exit(2);
  }

  const skills = listSkillFiles().map(parseSkill).filter((skill) => skill.adapterExpose);
  const stale = [];

  for (const target of targets) {
    const targetPath = path.default.join(root, target.path);
    const expected = renderTarget(target, skills);
    const actual = fs.default.existsSync(targetPath)
      ? fs.default.readFileSync(targetPath, "utf8")
      : null;

    if (check) {
      if (actual !== expected) {
        stale.push(target.path);
      }
      continue;
    }

    fs.default.mkdirSync(path.default.dirname(targetPath), { recursive: true });
    fs.default.writeFileSync(targetPath, expected);
    console.log(`wrote ${target.path}`);
  }

  if (check && stale.length > 0) {
    console.error("Generated agent adapters are stale:");
    for (const file of stale) {
      console.error(`  - ${file}`);
    }
    console.error("Run: node scripts/build-agent-adapters.js");
    process.exit(1);
  }

  if (check) {
    console.log("Generated agent adapters are current.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
