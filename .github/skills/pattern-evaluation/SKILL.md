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