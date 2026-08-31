---
name: convergence-check
description: Check that a completed change tells one consistent story across request, behaviour specification, architecture knowledge, implementation, tests, and delivery metadata, and report converged, converged with recorded waivers, not converged, or blocked. Use before declaring a pull request mergeable, before treating an implementation issue as complete, when asked whether a change is done, or when issues, specs, architecture documentation and code may have drifted apart.
---

# Convergence Check

## Purpose

A change is finished when its artifacts agree. Each one is reviewed on its own —
the issue at refinement, the scenario at specification, the ADR at decision, the
diff at review — and nothing looks across them at the end. Drift between two
individually correct artifacts is what this check exists to find.

It is a **gate**, not a phase. It adds no work of its own: it inspects what the
other skills already produced and reports whether it holds together.

## What it is not

- **Not a demand that artifacts say the same thing.** They sit at different
  abstraction levels and are supposed to. An issue states intent, a scenario
  states behaviour, an ADR states a decision and its cost. Convergence means no
  contradiction and no missing mandatory evidence, not repetition.
- **Not a repair tool.** A failed check produces findings and follow-up actions.
  It must never rewrite an accepted requirement, soften a recorded decision, or
  retarget a relation in order to make the artifacts agree. Making the evidence
  fit the conclusion is the failure this check is supposed to catch.
- **Not proof.** Only the deterministic tier proves anything. See
  "Automation boundary".

## When to run it

At least once, at the end:

- before a pull request is declared mergeable, and
- before an implementation issue is treated as complete.

Running it earlier is fine and cheap, but an early pass is not a result: the
artifacts it inspects are not all final yet.

## Every question must be able to fail

Before answering a question, know what evidence would make it fail for **this**
change. A question that cannot fail here is **not applicable**, and it is
reported as such.

Do not report a question as passed when it never had a way to fail. That is the
same defect as a scenario written to be green against unfixed code: a guard with
no failure path is worse than an absent guard, because it reads like coverage.

**Not applicable is not the same as blocked.** A question is *not applicable*
when it has no bearing on this change — nothing touched the deployment view, so
there is nothing there to contradict. It is an *unavailable blocker* when it does
bear on the change but cannot be answered at this layer. The first needs no
follow-up; the second does. See "Every blocker names its kind".

## The seven questions

### 1. Intent and scope

- Does the implemented change still match the Epic or UserStory it came from?
- Is every scope change reflected in the issue and the specification, rather
  than only in the diff?

### 2. Behaviour

- Is every added or changed observable behaviour described by a Gherkin
  scenario, or covered by an explicit recorded waiver?
- Is each scenario mapped to at least one automated verification under the
  bridge convention?
- Does any implemented edge case contradict the specification?

`../bdd-specification/SKILL.md` owns these rules. This check asks whether they
were met; it does not restate what a scenario or a bridge must look like.

### 3. Architecture impact

- Were the affected boundaries, components, interfaces, dependencies, runtime
  interactions, deployment elements, quality attributes, risks and constraints
  assessed?
- Were only genuinely affected architecture artifacts changed? Collateral
  updates to unaffected documents are a finding, not tidiness.

`../architecture-impact/SKILL.md` owns the assessment.

### 4. Decisions

- Are conflicts with existing ADRs resolved rather than left implicit?
- Is every architecture-significant decision recorded as an ADR, instead of
  living only in code or pull request discussion?
- Are the decisions that still need a human explicit?

Apply the proportionality rule from `../adr/SKILL.md`: a decision that does not
warrant an ADR is not a finding, and a missing ADR for a decision that does is.

### 5. Traceability

- Can the path from Epic or UserStory through specification and architecture
  impact to implementation, tests and pull request be followed?
- Are the authoritative outgoing relations valid, and were the derived views
  regenerated?

`../traceability-review/SKILL.md` owns relation review.

### 6. Implementation and verification

- Do code and configuration implement the specified behaviour and the recorded
  decisions?
- Do the relevant tests, validators, generators, render checks and builds pass?
- Are unavailable checks and residual risks reported rather than omitted?

### 7. Documentation and delivery state

- Do the issue, the pull request, the source documentation and the code describe
  the same resulting state?
- Are superseded assumptions and stale references removed, or explicitly kept
  with a valid lifecycle status?
- Do deliberately deferred pieces have follow-up issues?

## Automation boundary

Three tiers, and they must not be presented as one.

| Tier | What it is | Examples |
|---|---|---|
| **Deterministic** | Established from repository data; a machine decides | metamodel validation, adapter drift check, test and build results, dangling relation targets, regenerated fragments matching their source |
| **Assisted** | An assistant proposes findings a human confirms | contradiction between a scenario and an implemented edge case, an unrecorded decision, a stale reference, scope drift |
| **Human** | Only a person can decide | whether a decision is architecture-significant, whether a waiver is warranted, whether residual risk is acceptable |

**Never report an assisted finding as deterministic proof.** State the tier with
the finding. An assistant reporting "traceability is complete" without a
deterministic check behind it is asserting something it cannot know.

Prefer the deterministic tier wherever the rule can actually be established from
repository data — and add a deterministic check only where it can. A check that
merely looks deterministic is the same failure as a scenario that cannot fail.

## Result

One of four, stated explicitly:

| Result | Meaning |
|---|---|
| **Converged** | No unresolved contradiction, no missing mandatory evidence |
| **Converged with recorded waivers** | Deviations a human explicitly accepted, each with a traceable rationale |
| **Not converged** | Contradictions, missing links, missing verification, or undocumented decisions remain |
| **Blocked** | The gate cannot reach a result yet: required evidence or a required human decision is missing |

Not converged and blocked are both normal outcomes. Neither is a reason to
adjust the artifacts until the result improves.

### Every blocker names its kind

"Blocked" alone does not say what to do next, and the two kinds need opposite
actions:

| Kind | Meaning | What resolves it |
|---|---|---|
| **Pending** | The evidence or decision is obtainable; it does not exist yet | Name who must decide, or which check must run. Then run the gate again. |
| **Unavailable** | The evidence cannot be produced, or the question cannot be answered at this layer | A change of approach, or an explicit record of the limitation. Waiting does not help. |

A pending blocker is temporary and resolves by itself once the person decides or
the check runs — the gate then returns converged, converged with recorded
waivers, or not converged. An unavailable blocker does not resolve by waiting,
and reporting it as pending sends someone to wait for something that will not
arrive.

### A waiver is not a way out of a blocker

A waiver is a human decision about **proportionality** — "this is too small to
specify". It is a legitimate outcome of a **pending** blocker: the person decides
the deviation is acceptable, records the rationale, and the gate returns
*converged with recorded waivers*.

It is never an outcome of an **unavailable** blocker. There, the missing thing is
not disproportionate — it cannot be produced at all, and no amount of human
authority changes that. Recording an impossibility as an accepted deviation
buries the problem in a result that reads as agreement.

If a question turned out to be unanswerable at this layer, the honest report is
the unavailable blocker plus what would answer it elsewhere — not a waiver, and
not a passed question.

## Findings and follow-up

Every result that is not "converged" names concrete findings: what contradicts
what, which evidence is missing, and which tier established it.

Each finding gets one of four dispositions, and no finding is left without one:

- **fixed** in this change;
- **deferred** to a follow-up issue, referenced by number;
- **accepted** as a recorded waiver, with the rationale and who accepted it;
- **blocked**, naming the kind — pending, with who must decide or which check
  must run, or unavailable, with why and what would answer it elsewhere.

"Noted" is not a disposition. Neither is "blocked" on its own: a blocker without
its kind and its named next step is an open question wearing a status.

## Reuse, don't restate

This check composes rules it does not own. When a question needs a rule, read
the skill that owns it rather than reproducing the rule here — a second copy of
a rule in a gate is exactly the drift the gate is meant to detect.

## Required reading

Read the ones the change touches, not all of them:

- `../bdd-specification/SKILL.md` — behaviour specification and the test bridge
- `../architecture-impact/SKILL.md` — what counts as architecture impact
- `../adr/SKILL.md` — decision proportionality and lifecycle
- `../traceability-review/SKILL.md` — relation validity and derived views
- `../pr-review/SKILL.md` — how findings are reported on a pull request
- `../../general-semantic-contracts.md` — the engine-agnostic baseline
