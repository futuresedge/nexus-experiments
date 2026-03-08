# Task 1.2 — Gap Classification

**Input:** `brief-inventory.yaml`
**Output:** `open-questions-register.yaml` (initial population)

***

### Subtask 1 — Classify ABSENT/AMBIGUOUS Required Fields

**Input:** `fields[]` where `required: true` and `coverage ≠ PRESENT`; Step 2 and Step 3 policy documents (loaded)
**Output:** Register entries for required field gaps — questionid, field, gap, impact, gap_type, classification (BLOCKER | WARNING | INFO)

**Skills**

- Three-gate sequence applied in order: Gate 1 downstream failure, Gate 2 quality impact, Gate 3 required-field validity
- Step 2 and Step 3 policy loaded — Gate 1 is not executable without it
- `gap_type` precision — ABSENT, AMBIGUOUS-INCOMPLETE, AMBIGUOUS-FORMAT (determines Task 1.3 question type)
- One-gap-one-entry discipline — three `techstack` gaps produce three entries
- BLOCKER downgrade constraint — only Alex's CONFIRMED-UNKNOWN response permits downgrade; not executor judgment

**Failure Modes**

- Step 2/3 policy not loaded → Gate 1 is guesswork; BLOCKERs downgraded to WARNING
- Gate 3 not applied → `appetite` produces no BLOCKER; Task 1.4 writes non-enum value; self-check fails
- Three gaps collapsed into one entry → compound clarification question; paragraph response cannot be parsed
- AMBIGUOUS-FORMAT misclassified as AMBIGUOUS-INCOMPLETE → value-retrieval question sent instead of confirmation

***

### Subtask 2 — Classify ABSENT/AMBIGUOUS Optional Fields

**Input:** `fields[]` where `required: false` and `coverage ≠ PRESENT`
**Output:** Register entries for optional field gaps — classification WARNING | INFO (never BLOCKER)

**Skills**
- All optional fields visited explicitly — Done condition requires confirmation, not just entry creation
- WARNING vs INFO threshold — impact-based against a named downstream output, not intuition
- Conditional requirement recognition — `integrationrequirements` becomes WARNING when a form is declared
- `schema_gap_flag: true` for content with no manifest field — distinct from ABSENT optional field

**Failure Modes**
- Implicit conditional requirement missed → `integrationrequirements` becomes INFO; Step 2 consequence not surfaced at Task 1.5
- Optional field silently skipped → register appears complete; Done condition cannot be confirmed
- `schema_gap_flag` not set for non-schema content → infrastructure readiness signal lost

***

### Subtask 3 — Classify Contradictions

**Input:** `contradictions[]` from `brief-inventory.yaml`; full `fields[]` for linked entry identification
**Output:** Register entries for contradictions — always BLOCKER; bidirectional `linked_questions[]` populated for all related entries

**Skills**
- Contradiction classification is always BLOCKER — no exceptions, no domain-knowledge downgrade
- Linking pass as a named distinct step — after all entries created; bidirectional; not incremental
- Linked group identification — find the shared underlying cause, not just shared field names
- `impact` field specificity — names the exact Step 2 field or output that fails

**Failure Modes**
- Contradiction downgraded to WARNING using domain knowledge → FC-1 violation; Task 1.3 never asks; one side enters manifest as executor's choice
- Linking pass skipped → Task 1.3 formulates two questions for the same issue; one response resolves both; second entry stays OPEN; Task 1.4 blocked
- `impact` is generic → Task 1.3 impact statement is vague; Alex's response is vague; resolution is unclear

***

### Subtask 4 — Classify Non-Mappable Statements

**Input:** `non_mappable[]` from `brief-inventory.yaml`
**Output:** Register entries for consequential non-mappable statements (`schema_gap_flag: true`); documented no-entry decisions for inconsequential ones

**Skills**
- Downstream consequence assessment against Steps 2–6, not Step 1 only
- Explicit no-entry documentation — every `non_mappable[]` entry assessed; outcome recorded
- `schema_gap_flag` with actionable `candidate_field` suggestion

**Failure Modes**
- Subtask 4 skipped entirely → OQ-1-11/12/13 never created; `openquestions` missing entries Alex should see
- No-entry decisions not documented → verifier cannot distinguish "assessed inconsequential" from "never assessed"
