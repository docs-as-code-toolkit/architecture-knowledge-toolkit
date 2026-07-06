# Prompt Templates

This directory contains reusable prompts for applying the
architecture-knowledge-toolkit skills and contracts from another project.

Each prompt follows the same lookup rule:

1. Use an applicable local skill first.
2. If no local skill exists, look for the skill in the local
   architecture-knowledge-toolkit.
3. If no local architecture-knowledge-toolkit is available, look for a suitable
   skill in the public toolkit repository:
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

## Bootstrap Prompts

- [`bootstrap-greenfield.md`](bootstrap-greenfield.md) for projects that only
  have an idea or initial product intent.
- [`bootstrap-existing-artifacts.md`](bootstrap-existing-artifacts.md) for
  projects that already contain code, README files, diagrams, ADRs, or generic
  architecture documentation.

## Skill Prompts

- [`apply-contracts.md`](apply-contracts.md) for applying local and toolkit
  contracts to a task.
- [`adr.md`](adr.md) for Architecture Decision Records and impact analysis.
- [`bootstrap-project.md`](bootstrap-project.md) for toolkit-oriented project
  bootstrapping.
- [`commit-message.md`](commit-message.md) for repository commit messages.
- [`domain-modeling.md`](domain-modeling.md) for ubiquitous language and domain
  model refinement.
- [`grilling.md`](grilling.md) for stress-testing a plan through focused
  questioning.
- [`grill-me.md`](grill-me.md) for asking the assistant to run a grilling
  session.
- [`grill-with-docs.md`](grill-with-docs.md) for grilling plus documentation
  updates.
- [`implement-issue-workflow.md`](implement-issue-workflow.md) for GitHub issue
  implementation.
- [`post-merge-sync.md`](post-merge-sync.md) for local cleanup after PR merge.
- [`pr-review.md`](pr-review.md) for pull request review.
- [`quality-scenario.md`](quality-scenario.md) for measurable quality
  scenarios.
- [`risk.md`](risk.md) for architecture risk work.
- [`slice-issues.md`](slice-issues.md) for decomposing GitHub issues into
  reviewable slices.
- [`traceability-review.md`](traceability-review.md) for metadata relation
  reviews.

## Migration Prompts

- [`migrate-local-contract.md`](migrate-local-contract.md) for aligning a local
  project contract with the toolkit contract.
- [`migrate-local-skill.md`](migrate-local-skill.md) for aligning one local
  skill with the toolkit equivalent.
- [`migrate-local-skill-set.md`](migrate-local-skill-set.md) for auditing and
  aligning a whole local skill set.
