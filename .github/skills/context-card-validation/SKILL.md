# Context Card Validation Skill

**Loaded by:** ContextCurator
**Purpose:** Validate that a context card provides minimum sufficient
context — enough that the receiving agent can do its job well, and
no more than necessary to keep the context window efficient.

---

## Context Card Anatomy

A valid context card has exactly these sections:

```
***
agent_class:     [exact class name from roster]
task_id:         [task identifier]
context_type:    execution | qa | post-deploy | zone-0 | bootstrap
created_by:      ContextCurator
created_at:      [timestamp]
***

## Task Brief
[≤ 100 words. What this task does and why it matters.
 Scope: this task only, not the full feature.]

## Acceptance Criteria
[Verbatim from the AC document. Do not paraphrase.
 Include only the AC items relevant to this task.]

## Proof Criteria Summary
[Key criteria from the proof template this agent needs to know about.
 TaskPerformer: all criteria. Reviewers: criteria within their scope.]

## Relevant Patterns
[1–5 pattern references. Title + one-line approach summary only.
 Full pattern content is available via search_knowledge_base.]

## Constraints
[Tech stack constraints from environment contract, filtered to
 what this agent type can act on. Not the full contract.]

## Environment
[Environment contract fields relevant to this agent's actions.
 TaskPerformer: build + test commands. EnvironmentReviewer: full contract.
 QAOrchestrator: none needed.]

## Boundaries
[What this agent must NOT do. Drawn from NEVER list in agent spec.
 At least one entry. Never empty.]

## Conflicts and Flags
[Any detected inconsistencies between sections. Empty if none.
 If this section is non-empty, the card cannot be submitted until
 conflicts are resolved or explicitly accepted as risks.]
```

---

## The Four-Pass Compression Rubric

Apply these passes in order before writing each card section. Every
piece of information must pass all four to be included.

**Pass 1 — Necessity**
Does the agent need to act on this information to complete their job?
If no → exclude. Information that is interesting but not actionable
by this agent in this task is noise.

**Pass 2 — Availability**
Is this information already available via a document the agent reads
directly (task spec, proof template)? If yes → reference the document,
do not duplicate the content. Duplication creates staleness risk.

**Pass 3 — Scope**
Is this information verifiable or actionable within this task's scope?
If no — it belongs to a different agent or a different task scope →
exclude.

**Pass 4 — Consistency**
Does this information conflict with anything already included in the
card? If yes → do not silently resolve. Flag in Conflicts and Flags.
A card with a known conflict cannot be submitted.

---

## Per-Section Validation Checklist

Work through this checklist for every card before calling
`submit_context_ready`.

### Task Brief
- [ ] ≤ 100 words
- [ ] Describes what the task does (not what the feature does)
- [ ] Describes why it matters in one sentence (not a feature essay)
- [ ] Does not contain implementation instructions (those are in the spec)
- [ ] Does not contain acceptance criteria (those are in their own section)

### Acceptance Criteria
- [ ] Text is verbatim from the AC document — not paraphrased
- [ ] Only includes AC items relevant to this task
- [ ] Does not include feature-level AC unless the task directly
      implements a feature-level requirement
- [ ] Each item is individually identifiable (numbered or labelled)

*(Rationale for verbatim: paraphrased AC introduces translation error.
The agent receiving the card should be reading the same words the
FeatureOwner wrote. A paraphrase, however careful, is an interpretation.)*

### Proof Criteria Summary
- [ ] Lists only criteria from the proof template (no invented criteria)
- [ ] TaskPerformer cards: all criteria listed
- [ ] ProofReviewer cards: all criteria listed (reviewer checks all)
- [ ] ACReviewer cards: criteria with AC references listed
- [ ] EnvironmentReviewer cards: environment-related criteria only
- [ ] QAOrchestrator cards: none needed (QAOrchestrator reads
      individual reviews, not criteria)

### Relevant Patterns
- [ ] 1–5 patterns only. If more seem relevant, select the 5 most
      directly applicable and note that others are available via
      `search_knowledge_base`.
- [ ] Each entry: title + one-line approach summary only.
      Full pattern content is not included in the card.
- [ ] All patterns are PROVISIONAL or ACTIVE status.
      CANDIDATE patterns are not included in cards.
- [ ] Patterns are actually applicable to this task type.
      A Tailwind pattern is not relevant to a Deployer's card.
- [ ] If no patterns apply: include the explicit declaration
      "No applicable patterns found for this task type."
      Do not leave this section empty.

### Constraints
- [ ] Drawn from the environment contract — not invented
- [ ] Filtered to constraints this agent can act on
      (ContextCurator's constraint about "no React" is irrelevant
       to Deployer's card)
- [ ] No constraints that duplicate what's in the proof template
      (e.g., "Lighthouse score ≥ 90" is a proof criterion, not a
       card constraint)

### Environment
- [ ] Only fields the agent will interact with
- [ ] Values are current (match the latest environment contract version)
- [ ] EnvironmentReviewer cards: full contract included
      (EnvironmentReviewer is the only agent that needs the full
       environment contract in its context card)
- [ ] TaskPerformer cards: build command, test command, start command,
      local dev port — nothing else needed
- [ ] QAOrchestrator, ProofReviewer, ACReviewer cards: none
      (these agents review documents, not the environment directly)

### Boundaries
- [ ] Non-empty. Every agent has at least one thing it must not do.
- [ ] Drawn from the NEVER list in the agent's class definition
- [ ] Stated as clear prohibitions ("Never write to task specs",
      "Never modify the proof template after task is IN_PROGRESS")
- [ ] Does not contain vague guidance ("be careful", "use judgment")

### Conflicts and Flags
- [ ] All detected conflicts listed — none silently resolved
- [ ] Each conflict identifies: the two contradicting sources,
      what they say, and why they conflict
- [ ] If no conflicts: section is empty (not "none found" — empty)
- [ ] If conflicts exist: card cannot be submitted until resolved

---

## Special Case — EnvironmentReviewer Dual Context

EnvironmentReviewer receives two different context cards for the
same task: one for QA phase (pre-deploy) and one for Release phase
(post-deploy). These are not the same card with minor differences —
they are structurally different cards.

| Field | QA context card | Post-deploy context card |
|---|---|---|
| context_type | `qa` | `post-deploy` |
| Task Brief | Focused on verifying proof vs contract | Focused on verifying live deployment vs contract |
| Proof Criteria Summary | Environment-related proof criteria | None (post-deploy uses different evidence) |
| Environment | Pre-deploy verification steps | Post-deploy health check steps |
| Boundaries | "Never verify deployed URL — only local/staging env" | "Never verify local environment — only production URL" |

Generate both cards at the SPEC_APPROVED stage. ContextCurator holds
a `write_context_card_{agent}_{context_type}_{task_id}` tool for
each. Both must be validated before `submit_context_ready` is called.

---

## Common Card Errors

**Over-inclusion:** The entire feature spec is included when only
the task brief is needed. Apply Pass 2 (availability) — the agent
can read the task spec directly.

**Paraphrased AC:** "Make the contact form work" instead of the
actual AC text. Always verbatim.

**Stale environment:** Environment fields copied from an old version
of the contract that has since been updated. Always read the current
version of `environment-contract.md` when generating a card, not
a cached version.

**Irrelevant patterns:** A pattern for a different tech stack or
task type was included because the title sounded relevant. Check
the applicability conditions before including, not just the title.

**Missing boundaries:** The NEVER section is empty. Every agent
has scope boundaries. If you cannot identify any, re-read the agent
class definition.

**Conflicts silently resolved:** Two sources disagree and the card
includes one version without flagging the conflict. This is a
framework invariant violation — the agent receiving the card will
operate on a hidden assumption.

**Too short:** A card that is too sparse leaves the agent to infer
context it should have been given. The goal is minimum sufficient,
not minimum possible. An agent that cannot complete the pre-flight
check because the card is too sparse is a card quality failure.

---

## Freshness Check

Before submitting any card, verify:
- Task spec: is the version you read the current approved version?
- AC: same check.
- Proof template: same check.
- Environment contract: is this the version EnvironmentContractAuthor
  last approved? Check the document version, not the file modification
  date.
- Patterns: are all referenced patterns still PROVISIONAL or ACTIVE?
  If a pattern was deprecated since you read it, remove it from the card.

A card built from stale sources is invalid even if all other checks
pass. Stale context is treated the same as missing context.