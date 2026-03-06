Good. The existing `uncertainty-protocol.skill.md` covers the mechanics of *how* to raise uncertainty — the tool call, inputs, schema. What we need are the four listed skills, which are all about *judgment* — what to classify, how to write, how to evaluate, how to validate. These are companions to the protocol, not replacements.

Let me do the full inventory first, then write the four.

***

## Full Skills Inventory

| Skill File | For | Exists? |
|---|---|---|
| `uncertainty-protocol.skill.md` | All agents — HOW to raise | ✅ Exists (aligned, keep) |
| `uncertainty-classification.skill.md` | UncertaintyOwner — WHAT TYPE, WHO routes | ❌ Write now |
| `proof-template-writing.skill.md` | ProofDesigner | ❌ Write now |
| `pattern-evaluation.skill.md` | FrameworkOwner | ❌ Write now |
| `context-card-validation.skill.md` | ContextCurator | ❌ Write now |
| `compression.skill.md` | ContextCurator — compression rubric | ❌ Write next (source material exists in file:8) |
| `agent-spec-writing.skill.md` | TemplateAuthor | ❌ Write next |
| `agent-spec-reviewing.skill.md` | AgentSpecReviewer | ❌ Write next |
| `project-registration.skill.md` | ProjectRegistrar | ❌ Write next |
| `environment-contract-writing.skill.md` | EnvironmentContractAuthor | ❌ Write next |
| `pattern-seeding.skill.md` | PatternSeeder | ❌ Write next |
| `bootstrap-validation.skill.md` | BootstrapValidator | ❌ Write next |
| `terminal-report-writing.skill.md` | All agents — Learning Layer | ❌ Write next |

**Writing now:** the four listed (classification, proof-template-writing, pattern-evaluation, context-card-validation). These are the most foundational — they govern the quality of all downstream work.

***

## `.skills/uncertainty-classification.skill.md`

```markdown
# Uncertainty Classification Skill

**Loaded by:** UncertaintyOwner
**Companion to:** uncertainty-protocol.skill.md (mechanics of raising)
**Purpose:** Classify the type of uncertainty raised, route it to the
correct resolution authority, and ensure the raising agent receives
a usable resolution — not just an acknowledgement.

---

## When This Skill Applies

This skill activates whenever an agent calls `raise_uncertainty`. The
UncertaintyOwner receives the raise event and must:
1. Classify the uncertainty type
2. Identify the resolution authority
3. Route with sufficient context for fast resolution
4. Return the resolution to the raising agent explicitly

---

## The Five Uncertainty Types

### Type 1 — Spec Gap
**Definition:** The task specification does not tell the agent what to
do in the situation encountered. The agent has the capability to act,
but not the instruction to guide the action.

**Signals:**
- "The spec says X but doesn't say what to do when Y"
- "Two parts of the spec contradict each other"
- "The AC is satisfied by multiple approaches and the spec doesn't
  indicate which"
- "A condition exists that the spec author didn't anticipate"

**Resolution authority:** TaskOwner
**Resolution form:** A spec amendment or a clarification appended to
the task spec. Not a verbal resolution — the document changes.
**Typical resolution time:** Fast. TaskOwner reads the spec and the
gap signal and adds a clarification.

---

### Type 2 — Tool Gap
**Definition:** The agent needs a capability it does not hold.
The agent knows what to do but cannot do it with its current tool set.

**Signals:**
- "I need to write to a file I don't have a write tool for"
- "I need to read a document that isn't in my READS list"
- "I need to trigger a state transition I don't hold a submit tool for"

**Resolution authority:** FrameworkOwner
**Resolution form:** Either a tool is added to the agent's scope for
this task (FrameworkOwner decision) or the action is confirmed to be
out of scope (and the spec is adjusted accordingly).
**Important:** A tool gap that recurs across multiple agents is a
roster gap — the wrong agent is doing the work, or a new agent class
is needed. Flag recurring tool gaps to FrameworkOwner as a pattern.

---

### Type 3 — Environment Gap
**Definition:** The live environment does not match the environment
contract. Something the agent was told to assume is true is not true.

**Signals:**
- "The build command in the environment contract fails"
- "A service declared in the contract is unreachable"
- "A file path in the contract does not exist"
- "A version declared in the contract does not match the installed version"

**Resolution authority:** EnvironmentContractAuthor + human:director
**Resolution form:** The environment contract is updated to reflect
reality, OR the environment is corrected to match the contract.
The resolution authority decides which. The agent cannot resolve this
unilaterally — an environment gap means either the documentation
or the system is wrong, and only a human can decide which.

---

### Type 4 — Authority Gap
**Definition:** The agent needs to take an action that is outside its
defined scope — it would require overriding its NEVER list or acting
on an artefact it doesn't own.

**Signals:**
- "Completing this task would require me to modify a file in my NEVER list"
- "The logical next step belongs to a different agent class"
- "I'm being asked to do something that isn't in my job statement"

**Resolution authority:** FrameworkOwner
**Resolution form:** Either the scope boundary is confirmed (the agent
is correct to stop) or the task spec is reassigned to the correct agent.
Never resolved by relaxing the NEVER list at runtime.

---

### Type 5 — Novel Situation
**Definition:** The situation has no precedent in the pattern library,
no applicable spec guidance, and no clear resolution path. The agent
cannot make a reasonable inference.

**Signals:**
- "No pattern in the library applies to this"
- "The spec is silent on this entire category of situation"
- "This combination of conditions has never been encountered before"
- "Following the spec would produce an outcome that seems clearly wrong,
  but I have no authority to deviate"

**Resolution authority:** human:director
**Resolution form:** A direct human decision. This is the uncertainty
type that most often results in a new pattern being added to the library
after resolution.
**Important:** Do not classify as Type 5 to avoid the work of classifying
more precisely. Type 5 is a last resort. If a more specific type applies,
use it — Type 5 routes to human:director, which is the most expensive
resolution path.

---

## Classification Decision Tree

```
Start: an agent called raise_uncertainty.

Step 1: Does the agent have the capability but lack instruction?
  YES → Type 1 (Spec Gap) → route to TaskOwner

Step 2: Does the agent lack the tool to do what the spec asks?
  YES → Type 2 (Tool Gap) → route to FrameworkOwner

Step 3: Does the environment not match the environment contract?
  YES → Type 3 (Environment Gap) → route to EnvironmentContractAuthor
        + flag to human:director if contract correction needed

Step 4: Would the action violate the agent's NEVER list or scope?
  YES → Type 4 (Authority Gap) → route to FrameworkOwner

Step 5: None of the above apply and no reasonable inference exists.
  → Type 5 (Novel Situation) → route to human:director
```

---

## What to Include When Routing

Regardless of type, every routed uncertainty must include:

```
uncertainty_id:      [generated]
task_id:             [task this occurred in]
raising_agent:       [agent class + instance]
type:                [1-5 and type name]
state_at_raise:      [task working state when raised]
condition:           [exact condition encountered — specific, not vague]
what_was_tried:      [what the agent checked before raising]
resolution_needed:   [what would unblock the agent — specific ask]
relevant_refs:       [document paths the agent was reading]
```

The `resolution_needed` field is the most important. A routed
uncertainty with a vague resolution request ("I need clarification")
creates unnecessary back-and-forth. The resolution ask should be
answerable with a single decision or document change.

---

## Returning the Resolution

When the resolution authority responds, UncertaintyOwner:

1. Records the resolution in the uncertainty log
2. Closes the uncertainty instance
3. Updates the raising agent's context — not just the log.
   The agent must receive the resolution explicitly, either via:
   - An updated context card (if the resolution changes a document)
   - A direct resolution message (if the resolution is a decision)
4. Emits an `UncertaintyResolved` stream event
5. Task resumes from its prior working state

**A resolution that the raising agent cannot act on is not a resolution.**
If the resolution authority provides an answer that still leaves the
agent unable to proceed, the uncertainty is still open.

---

## What Is NOT Uncertainty

Do not route these as uncertainties — they are normal work:

- **A choice between two valid approaches** where both satisfy the
  spec. Make the decision, log it in the work log, proceed.
- **A step that is difficult** but the spec is clear. Difficulty is
  not uncertainty.
- **A detail the spec omits** that can be reasonably inferred from
  context. Infer, log the inference, proceed. Only raise if the
  inference would be unreasonable or if being wrong would be costly.
- **A tool call that returns an error** on first attempt. Retry once
  with corrected inputs. Raise uncertainty only if the error persists
  after a reasonable retry.

---

## Aggregate Pattern Recognition

After each resolved uncertainty, assess:
- Has this same type of uncertainty been raised before on this project?
- Has this uncertainty type been raised by multiple different agents?

If yes to either: flag to FrameworkOwner as a potential structural gap.
Recurring uncertainties of the same type are framework signals, not
task anomalies. They indicate:
- Type 1 recurring → systematic spec quality issue
- Type 2 recurring → roster or tool assignment gap
- Type 3 recurring → environment contract is out of date
- Type 4 recurring → agent scope is mis-drawn
- Type 5 recurring → a pattern is missing from the library
```

***

## `.skills/proof-template-writing.skill.md`

```markdown
# Proof Template Writing Skill

**Loaded by:** ProofDesigner
**Purpose:** Write proof templates that are unambiguous contracts —
where any competent reviewer can determine pass or fail without
judgment, and any competent performer knows exactly what evidence
to produce.

---

## The Central Rule

A proof template criterion is only valid if a reviewer who has never
seen the task can read the criterion and the submitted evidence and
determine pass or fail without making a judgment call.

If the reviewer needs to use judgment, the criterion is not specific
enough. Rewrite it until the answer is mechanical.

---

## Anatomy of a Proof Template

```
***
task_id:       task-XX
task_name:     [human-readable name]
authored_by:   ProofDesigner (never TaskPerformer)
qa_tier:       [0-4 from task spec]
created:       [date]
***

## Criterion [N]: [Short name]

description:
  [What this criterion verifies. One to three sentences.
   Describe the property being checked, not the implementation.]

evidence_required:
  [Exact description of what evidence must be submitted.
   Include: format, source, and scope.]

passing_condition:
  [The precise condition that constitutes a pass.
   Must be binary — either it passes or it doesn't.]

failing_condition:
  [What would make this criterion fail.
   Explicit, not implied from the passing condition.]
```

Repeat for each criterion. Every AC item produces at least one
criterion. A complex AC item may produce multiple criteria.

---

## Criterion Quality Rules

### Rule 1 — One verifiable property per criterion
Each criterion checks exactly one thing. A criterion that checks
"the form submits and the user receives a confirmation email" is
two criteria: form submission and email delivery. Split it.

### Rule 2 — Evidence format is specified
Do not write "tests pass" — write "the output of `pnpm test` contains
no failing test lines and exits with code 0." The reviewer should
know exactly what to look for before seeing the submission.

### Rule 3 — Passing condition is binary
"Performance is acceptable" is not binary. "Lighthouse performance
score ≥ 90 on three consecutive runs on the staging URL" is binary.
If you find yourself writing "reasonable", "adequate", "good", or
"appropriate" — stop. Replace with a number, a threshold, or a
specific observable state.

### Rule 4 — Failing condition is explicit
Do not make the reviewer infer the failure condition from the passing
condition. State it. "The build exits with code 1" is clearer than
leaving the reviewer to infer that non-zero exit = fail.

### Rule 5 — Evidence is producible before deployment
Proof is submitted before APPROVED state. All evidence must be
producible in the task's execution environment, not in production.
If a criterion can only be verified post-deployment, it belongs in
the post-deploy review, not the proof template.

---

## Translating Acceptance Criteria Into Criteria

Work through each AC item in sequence.

For each AC item, ask:
1. **What is the observable outcome?** Not the implementation, the
   outcome. "A user can submit the contact form" is an outcome.
   "The `handleSubmit` function is called" is an implementation detail.

2. **What evidence would prove this outcome occurred?** For each
   outcome, identify what the TaskPerformer can capture as proof.
   Prefer objective over subjective evidence. Prefer automated over
   manual evidence.

3. **Is this one criterion or multiple?** If an AC item contains
   "and", it is likely multiple criteria. Split before writing.

4. **Is this criterion testable in the execution environment?**
   If not, flag this to TaskOwner before writing the template.
   An untestable criterion is a spec problem, not a proof problem.

If an AC item is ambiguous, raise uncertainty to TaskOwner before
writing the criterion. Do not write a criterion around an ambiguous
AC — you will produce a template that can be gamed.

---

## Evidence Type Taxonomy

Use the most objective evidence type available:

| Type | When to use | Example |
|---|---|---|
| **Command output** | Build, test, lint, type-check | `pnpm build` stdout + exit code |
| **File content** | Generated output verification | Contents of `dist/index.html` |
| **HTTP response** | API or page availability | `curl` status + response body excerpt |
| **Test results** | Functional verification | Full test runner output, not summary |
| **Screenshot** | Visual / UI criteria only | Annotated screenshot with visible element |
| **Metrics output** | Performance criteria | Lighthouse CLI JSON output |
| **Log excerpt** | Service behaviour | Specific log lines with timestamps |

Avoid "manual testing" as evidence. Manual testing is not verifiable
from a submitted proof document. If a criterion requires manual
testing, rewrite it as an automated check or flag it to TaskOwner.

---

## Common Anti-patterns

**"Works correctly"**
→ Works how? Under what conditions? For which inputs?
→ Replace with: the specific output for a specific input.

**"No errors"**
→ Which errors? Detected how? In which tool output?
→ Replace with: "the output of `pnpm build` contains zero lines
   matching the pattern `error:`".

**"Tests pass"**
→ Which tests? All of them? A specific suite?
→ Replace with: "the output of `pnpm test` shows 0 failed tests
   and exits with code 0."

**"Looks good"**
→ This is not a criterion. If visual quality matters, define it:
   what must be visible, where, at what viewport size?

**"Performance is acceptable"**
→ Define the metric, the threshold, and the measurement tool.

**"Compatible with the environment contract"**
→ This is EnvironmentReviewer's job, not a proof criterion.
   Remove it — it will be verified independently.

**Criteria that the TaskPerformer writes their own evidence for**
→ Proof criteria must be verifiable from captured outputs.
   If the TaskPerformer can write any evidence they like and it
   would "pass", the criterion is not a criterion — it is a checkbox.

---

## Self-Check Before Submitting

Before submitting a proof template, answer these questions:

1. Can a reviewer who has not seen this task read each criterion
   and know exactly what evidence to look for? (Yes / No — if No,
   rewrite the criterion.)

2. Could a TaskPerformer read this template and know, before writing
   a single line of code, what they need to produce as proof?
   (Yes / No — if No, rewrite.)

3. Does every AC item appear in at least one criterion? Check off
   each AC item against the criterion list. Gaps are missing criteria.

4. Are any criteria untestable in the execution environment? If yes,
   raise uncertainty to TaskOwner before submitting.

5. Did you write any passing condition that requires judgment?
   ("Sufficient", "reasonable", "adequate" — all require judgment.)
   Replace all of these with measurable thresholds.
```

***

## `.skills/pattern-evaluation.skill.md`

```markdown
# Pattern Evaluation Skill

**Loaded by:** FrameworkOwner
**Purpose:** Evaluate candidate patterns for promotion into the Pattern
Library, assess active patterns for retirement, and maintain the library
as a useful, non-redundant knowledge base.

---

## Pattern Schema

Every pattern in the library has these fields:

```
pattern_id:          [auto-generated]
title:               [Short, verb-noun: "Astro component colocation"]
problem:             [One sentence: what situation does this address?]
approach:            [How to address it. Concrete, not abstract.]
evidence:            [What makes you believe this works?
                      Source: task retro, seeded, external reference.]
applicability:       [When to use this pattern.]
contraindications:   [When NOT to use this pattern. Mandatory field.]
status:              CANDIDATE | PROVISIONAL | ACTIVE | DEPRECATED | RETIRED
source:              [task retro / seeded / FrameworkOwner judgment]
promoted_by:         [agent or human who promoted to current status]
promoted_date:       [date of last promotion]
usage_count:         [how many tasks have applied this pattern]
failure_count:       [how many tasks applying this pattern had QA failures
                      attributable to it]
```

`contraindications` is mandatory. A pattern with no contraindications
is either a principle (too broad) or needs more thought.

---

## Promotion Lifecycle

```
CANDIDATE
  Identified in a terminal report or seeded during bootstrap.
  Not yet validated. Not surfaced in context cards.
  Any agent may produce a CANDIDATE. Only FrameworkOwner promotes.
  ↓ (FrameworkOwner evaluation — see Gate 1 below)
PROVISIONAL
  Plausible evidence basis. Valid structure. Ready for use.
  Surfaced in context cards for relevant task types.
  Requires at least 1 successful application to advance.
  ↓ (FrameworkOwner evaluation after ≥ 3 applications — see Gate 2)
ACTIVE
  Proven across multiple tasks. High confidence.
  Prioritised in context card inclusion.
  ↓ (FrameworkOwner evaluation on failure signal — see Gate 3)
DEPRECATED
  Flagged for retirement. Still visible but marked unreliable.
  ContextCurator does not include DEPRECATED patterns in cards.
  ↓ (FrameworkOwner confirms no active dependencies)
RETIRED
  Removed from context card consideration entirely.
  Kept in library for historical audit purposes only.
```

---

## Gate 1 — CANDIDATE → PROVISIONAL

Evaluate the candidate against these questions. All must be YES
to promote:

1. **Is the problem statement specific?**
   Does it describe a concrete, recurring situation rather than a
   general principle? ("How to configure Netlify adapter for static
   output" is specific. "Write good configuration" is not.)

2. **Is the approach concrete?**
   Can an agent read the approach and take an action? Or does it
   require interpretation? If it requires interpretation, it needs
   more specificity before promotion.

3. **Is there a plausible evidence basis?**
   For seeded patterns, the evidence is prior knowledge of the tech
   stack — this is acceptable at CANDIDATE → PROVISIONAL. For
   task-retro patterns, the evidence is the retro record.
   "I think this is a good idea" without any basis is not evidence.

4. **Are the applicability conditions specific enough?**
   Can a ContextCurator decide whether to include this pattern
   in a context card without needing to read the full pattern?
   If the applicability is "whenever you're building something",
   it is not specific enough.

5. **Is there at least one contraindication?**
   Every valid pattern has situations where it does not apply or
   would cause harm. If no contraindication can be identified, the
   pattern is likely a principle, not a pattern.

6. **Is this pattern distinguishable from existing patterns?**
   Check the library for near-duplicates. If a very similar pattern
   exists, either: merge them, or define clearly how they differ
   and when each applies.

If any answer is NO, return the candidate with the specific gap
identified. Do not promote with known gaps.

---

## Gate 2 — PROVISIONAL → ACTIVE

Evaluate after ≥ 3 task applications:

1. **Usage count ≥ 3** — at least three distinct tasks applied this
   pattern (not three rounds of the same task).

2. **Failure count = 0** — none of the applications resulted in a
   QA failure attributable to following this pattern.
   Note: a task may fail QA for reasons unrelated to a pattern it
   applied. Only attribute a failure to a pattern if the failure
   finding specifically calls out following the pattern as the cause.

3. **Evidence has been updated** — the evidence field should now
   reference specific task retros, not just the original seed basis.

4. **Contraindications remain accurate** — did any of the three
   applications reveal a new contraindication? If yes, update before
   promoting.

If usage_count ≥ 3 but failure_count > 0, investigate before
promoting. A 1-in-3 failure rate means the pattern needs refinement
or narrower applicability conditions, not promotion.

---

## Gate 3 — ACTIVE → DEPRECATED

Trigger conditions (any one is sufficient):

- **Failure count increases** — a second QA failure attributable to
  this pattern. One failure can be an anomaly. Two is a signal.
- **Tech stack change** — a framework update, a new version, or a
  project decision makes the pattern's approach invalid.
- **Superseded** — a newer, better-evidenced pattern addresses the
  same problem. The older one should be deprecated, not kept alongside.
- **FrameworkOwner judgment** — the pattern is producing confused or
  poor application in context cards. Even with no failures, a pattern
  that is consistently misapplied is not serving its purpose.

When deprecating, add a note to the pattern:
- Why it was deprecated
- What to use instead (if applicable)
- Date deprecated

---

## What Is NOT a Pattern

**A principle:** "Always verify before trusting" is a foundation
principle, not a pattern. Patterns are specific to a context and an
approach. Principles are universal. If a proposed pattern applies to
all tasks in all contexts, it's a principle — point to the relevant
foundation principle instead.

**A one-off task note:** "For task-07, the Netlify deploy hook needed
to be reset" is a task-specific note. It belongs in the task retro,
not the pattern library. A pattern must apply to a class of situations,
not a specific instance.

**An instruction:** "Read the environment contract before writing"
is a rule for all agents, not a pattern. If it applies universally,
it belongs in the agent design standards or copilot instructions.

**An anti-pattern:** Record these separately, labelled explicitly as
anti-patterns. An anti-pattern is a documented failure mode — "we tried
this, and here's why it failed". These are valuable but structurally
different from positive patterns.

---

## Pattern Library Health Signals

Review these metrics in each cycle retro:

- **High CANDIDATE count, low PROVISIONAL count:** Patterns are being
  identified but not evaluated. FrameworkOwner evaluation cadence is
  too slow.
- **High PROVISIONAL count, low ACTIVE count:** Patterns are not being
  applied enough to gather evidence. May indicate patterns are too
  narrow or ContextCurator is not surfacing them.
- **High DEPRECATED count:** The tech stack is changing faster than
  patterns are being updated, or the original seeding was low quality.
- **Patterns with usage_count = 1:** These are not yet proven. Be
  cautious about promoting them; weight them lightly in context cards.
- **Patterns with contraindications = "none":** These need review —
  a valid pattern always has conditions under which it does not apply.
```

***

## `.skills/context-card-validation.skill.md`

```markdown
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
```

***

## What to Write Next

The four skills above are the quality backbone for the most critical agents. The remaining skills break into two natural groups:

**Group A — Zone 0 skills** (needed before bootstrap can run):
- `compression.skill.md` — source material already exists in file:8; primarily a formalisation job
- `environment-contract-writing.skill.md`
- `project-registration.skill.md`
- `pattern-seeding.skill.md`
- `bootstrap-validation.skill.md`
- `agent-spec-writing.skill.md`

**Group B — Universal skills** (needed by all agents):
- `terminal-report-writing.skill.md` — every agent needs this; it's the Learning Layer's primary input

The most valuable to write next is `terminal-report-writing.skill.md` — it's universal and it determines the quality of everything the Learning Layer produces. After that, Group A in task sequence order (Z0-1 through Z0-5).