# Skill: Terminal Report Writing

TRIGGERS: "write terminal report", "task complete report",
          "learning report", "end of task report"
PHASE:    Cross-cutting — all phases, all zones
USED BY:  All agent classes


## What this skill does

Produces a structured record of what this agent did on a task,
what worked, what did not, and what should change. Written when
a task reaches a terminal state.

The terminal report is a learning instrument, not a compliance form.
A report that says "task completed successfully, no issues" is a
failed report — something always happened that is worth recording.
The goal is to make the next task cheaper to run than this one.


## When to Write

Write a terminal report when any of these states is reached:

  DONE        Task completed and approved — write a full report
  REJECTED    Task rejected (rework limit reached, or human:director
              decision) — write a full report; the failure cause
              is the most valuable part
  CANCELLED   Task cancelled — write a brief report covering what
              was in progress and why the cancellation occurred

Policy Engine PE-07 blocks final tool revocation until all expected
terminal reports are submitted. Do not wait to be reminded.

Write your own report. Do not read other agents' reports before
writing yours — your account must be independent.


---


## Part 1 — Terminal Report Schema

Every report uses this structure. Sections marked REQUIRED must
be non-empty. Sections marked CONDITIONAL apply only in
specified circumstances.

```
***
agent_class:      [AgentClassName]
task_id:          [task identifier]
feature_id:       [feature slug]
terminal_state:   [DONE | REJECTED | CANCELLED]
rounds:           [number of rework rounds this task went through]
report_written:   [ISO 8601]
***

## 1. What I Did on This Task
REQUIRED

[2–5 sentences. What was your specific job on this task?
 What artefact did you produce or review? Be concrete.

 GOOD: "I reviewed proof.md round 2 against proof-template.md.
        I checked 7 criteria. 5 passed, 2 failed: criterion
        PT-03 had no exit code captured, criterion PT-06 had
        a screenshot of the wrong viewport width."

 BAD:  "I performed my QA duties and reviewed the submitted
        proof for completeness."]


## 2. Rounds and Rework
CONDITIONAL — include if rounds > 1

round_count:    [N]
first_fail_cause: [What caused the first RETURNED verdict?
                   Specific — what exactly was wrong?]
resolution:     [What changed between the failing round and
                 the passing round? What fixed it?]
avoidable:      [yes | no | partial]
avoidable_how:  [If yes or partial: what upstream change would
                 have prevented the rework cycle?
                 Name the artefact and the specific gap.
                 "The proof template criterion PT-03 did not
                  specify that exit code must be captured —
                  only that build must succeed. Criterion
                  wording was ambiguous."]


## 3. Context Card Quality
REQUIRED

quality:        [sufficient | sufficient with gaps | insufficient]
used_sections:  [Which sections of your context card did you
                 actually use? Name them.]
unused_sections: [Which sections were present but not needed?
                  This informs ContextCurator compression.]
missing:        [What information was absent from the card that
                 you needed to do your job?
                 "None" is acceptable but requires confidence.]
wrong:          [What information in the card was incorrect or
                 stale at the time you used it?
                 "None" is acceptable but requires confidence.]

NOTE: This section is read by ContextCurator via TaskOrchestrator
      to improve future context cards for agents in your class.
      Vague responses degrade future card quality.


## 4. Patterns Used
CONDITIONAL — include if any patterns were applied

[List each pattern referenced from the context card or
 pattern library. For each, record whether it held up.]

- pattern_id:    [pattern identifier]
  applied:       [yes | partially | no — and why]
  outcome:       [Did applying the pattern produce the expected
                  result? If not, what happened instead?]
  recommendation: [promote | maintain | revise | retire]
  revision_note: [If revise: what specifically needs changing?]


## 5. Pattern Candidates
CONDITIONAL — include if anything emerged that should become a pattern

[Did you encounter an approach that worked well and would
 benefit future agents on similar tasks? Describe it here.
 FrameworkOwner uses this to seed new patterns.

 Format: problem → approach → evidence → applicability
 Must be specific enough to seed a pattern entry directly.

 NOT a pattern candidate: "communication was good"
 IS a pattern candidate: "For Netlify Forms, adding the
   hidden form-name input is required but not documented
   in the Netlify Forms quickstart. Without it, submissions
   are silently dropped. This should be in netlify-forms-native
   as an explicit step."]


## 6. Uncertainties Raised
CONDITIONAL — include if this agent raised any uncertainty

[For each uncertainty this agent raised:]

- uncertainty_id:   [from uncertainty-log]
  what:             [brief description of what was uncertain]
  resolved:         [yes | no | escalated]
  resolution_time:  [fast < 1hr | slow > 1hr | blocking]
  avoidable:        [yes | no]
  avoidable_how:    [If yes: which upstream artefact had the gap
                     that caused the uncertainty?]


## 7. Friction Points
REQUIRED

[What slowed you down or made your job harder than it should be?
 This is not a complaints section — it is a systems improvement
 section. Specific and actionable only.

 GOOD: "The proof template had 9 criteria but no grouping.
        Scanning for the two environment criteria required
        reading all 9 each time. A grouped format would help."

 BAD:  "The task was complex and took more effort than expected."

 If nothing slowed you down: write "None identified." — but only
 after genuinely asking whether that is true.]


## 8. Recommendations
CONDITIONAL — include if there is anything FrameworkOwner
              or the framework should know

[At most 3 items. Specific and actionable.
 Each recommendation names an artefact, policy, or process
 and states what should change and why.

 GOOD: "proof-template.skill.md should require that criteria
        reference AC item IDs explicitly. Criterion PT-03 had
        no AC reference and ProofReviewer could not verify
        whether it was covered by the AC or out of scope."

 BAD:  "The framework should be improved for clarity."]
```

Write to:
  `.framework/features/{feature}/tasks/{task}/
   terminal-reports/{AgentClass}-terminal-report.md`


---


## Part 2 — Terminal State Variations


### DONE reports — full schema, all sections

Write all sections. This is the highest-value report type because
it documents a success path that can be repeated. Be specific
about what made it work, not just that it did.


### REJECTED reports — full schema, emphasis on sections 2 and 7

Section 2 (Rounds and Rework) is the most important section in a
REJECTED report. The framework needs to understand what caused
the rejection — not to assign blame, but to close the gap that
allowed a task to reach rejection rather than catching it earlier.

If rejected after max rework rounds: record each round's fail
cause in section 2. If a pattern emerges across rounds (e.g.
the same criterion kept failing), name it explicitly.

If rejected by human:director decision (not rework limit): record
the stated rejection reason in section 1 and the specific
artefact state at the time of rejection.


### CANCELLED reports — abbreviated schema

Required: sections 1, 3, 7
Optional: section 8 if cancellation reveals a systemic issue

Section 1 for CANCELLED: describe what was in progress at the
time of cancellation. What stage had been reached? What had been
written? What had not been started?

Do not speculate about why the task was cancelled unless you have
direct knowledge from the uncertainty log or a human:director
instruction. Record what you know; leave the rest blank.


---


## Part 3 — Quality Bar

These are the tests TaskOrchestrator applies when aggregating
reports into the task-retro. Reports that fail these tests will
be noted in the task-retro as low-quality.


### Test 1 — Specificity

Every claim should be verifiable by reading the task artefacts.
"The proof template was unclear" is not specific.
"Proof template criterion PT-03 did not specify the expected
format for the exit code capture" is specific — someone can
read PT-03 and confirm or dispute it.


### Test 2 — No Actor Blame

Terminal reports are systems analyses, not performance reviews.
"ProofReviewer was too strict" → not acceptable.
"Criterion PT-03 was interpreted differently by TaskPerformer
and ProofReviewer — the criterion's wording supports both
interpretations" → acceptable.

Name artefacts and gaps. Do not name agents as causes.


### Test 3 — Context Card Section 3 is not empty without cause

If section 3 says "None" for both missing and wrong, that is a
strong claim. It means the context card was perfect for this task.
That is possible, but rare. If you are writing "None" for both,
confirm you have actually checked each section of the card against
what you needed. If you did not use the card closely, write
"did not verify — card not needed for this task type" rather than
"None."


### Test 4 — Pattern candidates are pattern-shaped

A pattern candidate in section 5 must have:
  - A problem statement (specific situation)
  - An approach (what to do)
  - Evidence (why it works)
  - Applicability (when to use it)

Missing any of these means it is a note, not a candidate.
FrameworkOwner cannot seed from a note. Write it as a note in
section 8 or drop it. Do not format it as a pattern candidate
if it is not pattern-shaped.


---


## Part 4 — What Not to Write

These are the most common failure modes. Reject these before
submitting.


  Outcome summaries with no analysis
    "Task completed in 2 rounds. Round 1 failed, round 2 passed."
    → This is audit log content, not a terminal report.
    The audit log already has this. The report must explain
    WHY round 1 failed and what changed.


  Generic friction
    "The task was large and complex."
    "There was a lot of context to process."
    → This is not actionable. What specifically was large?
    Which section of context was hard to process and why?


  Compliments
    "The context card was well-written and easy to use."
    → Not useful. Which sections? What made them easy?
    If a section was genuinely well-designed, name the design
    choice so ContextCurator can repeat it intentionally.


  Forward speculation
    "In future, agents should probably have more context."
    → This is a wish, not a recommendation. Name the specific
    artefact, the specific gap, and the specific change needed.


  Self-assessment of quality
    "I performed my role correctly and to a high standard."
    → The QA review assesses your output quality. The terminal
    report assesses the system conditions you worked in.
    These are different things.


---


## Self-Check Before Submitting

  [ ] agent_class matches your class name exactly
  [ ] terminal_state matches the actual final state of the task
  [ ] Section 1 is concrete — names specific artefacts and actions
  [ ] Section 2 included if rounds > 1, with avoidable_how filled
  [ ] Section 3 has specific section names, not "all sections"
  [ ] No actor blame in any section — only artefact/gap analysis
  [ ] Any pattern candidates in section 5 are pattern-shaped
      (problem + approach + evidence + applicability)
  [ ] Section 7 contains at least one item, or "None identified"
      with genuine confidence
  [ ] Report was written independently — not after reading other
      agents' reports for this task