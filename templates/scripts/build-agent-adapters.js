#!/usr/bin/env node

// Generic, parameterizable agent adapter generator for projects that consume the
// architecture-knowledge-toolkit. Copy this file (and check-agent-adapters.js)
// into a consuming project's scripts/ directory. Unlike the toolkit's own
// generator, this template is NOT wired to a fixed project name or routing mode:
//
//   Project name (used for adapter text and the Cursor rule file name) is taken
//   from, in order:
//     1. the AGENT_ADAPTER_PROJECT environment variable;
//     2. the "project" field of adapters/agent-adapters.config.json, if present;
//     3. the repository directory name.
//
//   Routing mode is auto-detected: if the project has local skills/**/SKILL.md,
//   they are listed and the toolkit covers everything else; if it has none, the
//   adapters route entirely to the toolkit.
//
// Run `node scripts/build-agent-adapters.js` to (re)generate the adapters and
// `node scripts/check-agent-adapters.js` to fail on stale adapters.

async function main() {
  const fs = await import("fs");
  const path = await import("path");
  const scriptDir = path.default.dirname(path.default.resolve(process.argv[1]));
  const root = path.default.resolve(scriptDir, "..");

  const toolkitUrl =
    "https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit";

  function resolveProjectName() {
    const fromEnv = process.env.AGENT_ADAPTER_PROJECT;
    if (fromEnv && fromEnv.trim()) {
      return fromEnv.trim();
    }
    const configPath = path.default.join(root, "adapters", "agent-adapters.config.json");
    if (fs.default.existsSync(configPath)) {
      try {
        const config = JSON.parse(fs.default.readFileSync(configPath, "utf8"));
        if (config && typeof config.project === "string" && config.project.trim()) {
          return config.project.trim();
        }
      } catch (error) {
        console.error(`Ignoring invalid ${path.default.relative(root, configPath)}: ${error.message}`);
      }
    }
    return path.default.basename(root);
  }

  const project = resolveProjectName();

  const generatedNotice = [
    "<!-- GENERATED FILE: edit the canonical skills or scripts/build-agent-adapters.js, then regenerate. -->",
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
    const hasSkills = skills.length > 0;

    const skillsIntro = hasSkills
      ? `Keep project semantics in repository-root \`general-semantic-contracts.md\`
and canonical \`skills/**/SKILL.md\` files. Architecture and
software-development-lifecycle work not covered by a local skill is delegated to
the architecture-knowledge-toolkit.`
      : `${project} keeps no local agent skills of its own; architecture and
software-development-lifecycle semantics are delegated to the
architecture-knowledge-toolkit.`;

    const selectStep = hasSkills
      ? `3. Select and read the relevant skill: a local skill from the list below when
   one applies, otherwise the matching canonical \`skills/**/SKILL.md\` from the
   architecture-knowledge-toolkit (see the toolkit lookup order in \`AGENTS.md\`).`
      : `3. Follow the toolkit lookup order in \`AGENTS.md\`, then read the relevant
   canonical \`skills/**/SKILL.md\` from the architecture-knowledge-toolkit.`;

    const localSkillsSection = hasSkills
      ? `\n## Local Skills

Paths are relative to the ${project} repository root.

${skills.map((skill) => `- \`${skill.name}\`: \`${skill.path}\``).join("\n")}
`
      : "";

    const body = `# ${target.title}

This is a thin ${target.agent}-specific wrapper for the ${project} repository.
${skillsIntro}

When ${target.agent} performs architecture-sensitive or AI-assisted work in this
repository:

1. Read repository-root \`AGENTS.md\`.
2. Read repository-root \`general-semantic-contracts.md\`.
${selectStep}
4. Treat this adapter as routing guidance only.
${localSkillsSection}
## Toolkit Source Of Truth

Prefer a local toolkit checkout when present (see the lookup order in
\`AGENTS.md\`); otherwise use the public repository:

${toolkitUrl}

## Adapter Boundary

Do not duplicate architecture, ADR, quality scenario, risk, traceability,
metadata, or arc42 rules here. Agent-specific files may only wrap, point to, or
invoke the canonical toolkit sources, local \`skills/\`, and repository-root
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

  // The Cursor rule file name follows the project name. If the project name
  // changes, an older generated rule would otherwise linger and leave several
  // `alwaysApply: true` rules active at once. Treat generated `.mdc` files under
  // adapters/cursor/rules as generator-owned: remove them (or flag them in check
  // mode) when they are not the current rule. Hand-authored rules without the
  // generated marker are left untouched.
  const generatedMarker = "GENERATED FILE: edit the canonical skills or scripts/build-agent-adapters.js";
  const cursorRulesDir = path.default.join(root, "adapters", "cursor", "rules");
  const expectedCursorPath = path.default.join(root, `adapters/cursor/rules/${project}.mdc`);
  if (fs.default.existsSync(cursorRulesDir)) {
    for (const entry of fs.default.readdirSync(cursorRulesDir).sort()) {
      if (!entry.endsWith(".mdc")) {
        continue;
      }
      const fullPath = path.default.join(cursorRulesDir, entry);
      if (fullPath === expectedCursorPath) {
        continue;
      }
      let content;
      try {
        content = fs.default.readFileSync(fullPath, "utf8");
      } catch {
        continue;
      }
      if (!content.includes(generatedMarker)) {
        continue;
      }
      const relPath = `adapters/cursor/rules/${entry}`;
      if (check) {
        stale.push(relPath);
      } else {
        fs.default.rmSync(fullPath);
        console.log(`removed ${relPath}`);
      }
    }
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
