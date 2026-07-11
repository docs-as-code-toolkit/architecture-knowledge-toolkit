#!/usr/bin/env node

// This example project keeps no local agent skills of its own. It delegates
// architecture and software-development-lifecycle semantics to the
// architecture-knowledge-toolkit. This generator therefore emits thin,
// toolkit-routing adapters. If local skills are ever added under skills/, they
// are listed as well, so the generator stays aligned with the toolkit template.

async function main() {
  const fs = await import("fs");
  const path = await import("path");
  const scriptDir = path.default.dirname(path.default.resolve(process.argv[1]));
  const root = path.default.resolve(scriptDir, "..");

  const project = "example";
  const toolkitUrl =
    "https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit";

  const generatedNotice = [
    "<!-- GENERATED FILE: edit scripts/build-agent-adapters.js (and skills/**/SKILL.md if present), then regenerate. -->",
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
      path: `adapters/cursor/rules/${project}.mdc`,
      title: "Cursor Rule",
      agent: "Cursor",
      wrap: (body) => `---
description: ${project} adapter
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
    if (!fs.default.existsSync(skillsDir)) {
      return [];
    }
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
    const localSkillsSection =
      skills.length > 0
        ? `\n## Local Skills

Paths are relative to the ${project} repository root.

${skills.map((skill) => `- \`${skill.name}\`: \`${skill.path}\``).join("\n")}
`
        : "";

    const body = `# ${target.title}

This is a thin ${target.agent}-specific wrapper for the ${project}
repository. ${project} keeps no local agent skills of its own; architecture and
software-development-lifecycle semantics are delegated to the
architecture-knowledge-toolkit.

When ${target.agent} performs architecture-sensitive or SDLC work in this
repository:

1. Read repository-root \`AGENTS.md\`.
2. Read repository-root \`general-semantic-contracts.md\`.
3. Follow the toolkit lookup order in \`AGENTS.md\`, then read the relevant
   canonical \`skills/**/SKILL.md\` from the architecture-knowledge-toolkit.
4. Treat this adapter as routing guidance only.
${localSkillsSection}
## Toolkit Source Of Truth

Prefer local toolkit files when present; otherwise use the public repository:

${toolkitUrl}

## Adapter Boundary

Do not duplicate architecture, ADR, quality scenario, risk, traceability,
metadata, or arc42 rules here. Agent-specific files may only wrap, point to, or
invoke the canonical toolkit sources and repository-root
\`general-semantic-contracts.md\`.
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
