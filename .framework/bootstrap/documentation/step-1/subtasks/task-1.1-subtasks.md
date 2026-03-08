# Task 1.1 — Brief Inventory

**Input:** Raw project brief, manifest schema
**Output:** `brief-inventory.yaml` (four arrays: `statements[]`, `fields[]`, `non_mappable[]`, `contradictions[]`)

***


### Subtask 1 — Statement Decomposition

**Input:** Raw brief, manifest schema
**Output:** `statements[]` — id, text (verbatim), clarity (CLEAR | AMBIGUOUS), candidate_fields[]

**Skills**
- Statement atomisation — one declarative claim per entry
- Clarity classification — name two competing interpretations before assigning AMBIGUOUS
- Candidate field assignment from loaded schema — real field names only
- Implicit statement recognition — surface unstated dependencies as separate entries
- Verbatim extraction — executor voice does not appear in `text`
- Tension noting without resolution — flag statement ID pairs, do not resolve

**Failure Modes**
- Compound statement collapsed into one entry → downstream traceability breaks; compound clarification question
- AMBIGUOUS assigned without two named interpretations → gap_type indeterminate; wrong question type in Task 1.3
- Implicit dependency not extracted → field classified ABSENT instead of AMBIGUOUS; wrong question asked
- Verbatim replaced by paraphrase → FC-1 fails at verification; source cannot be located
- Tension silently resolved → no entry in `contradictions[]`; constraint enters manifest unconfirmed

***

### Subtask 2 — Required Field Coverage Analysis

**Input:** `statements[]`, manifest schema (required fields, format rules, valid enums)
**Output:** `fields[]` entries where `required: true` — field, required, coverage (PRESENT | ABSENT | AMBIGUOUS-INCOMPLETE | AMBIGUOUS-FORMAT), supporting_statements[]

**Skills**
- PRESENT means format-compliant, not merely mentioned
- Per-field format rule knowledge — each field has its own compliance test
- AMBIGUOUS-INCOMPLETE vs AMBIGUOUS-FORMAT distinction — different question types in Task 1.3
- Multi-statement assembly detection — record all contributing statement IDs
- `humanactors` structural check — PRESENT requires a nameable humandirector role
- `appetite` enum awareness — ABSENT vs AMBIGUOUS-FORMAT are not the same

**Failure Modes**
- PRESENT assigned for mentioned-but-unversioned value → register entry created two tasks late
- AMBIGUOUS-INCOMPLETE used where AMBIGUOUS-FORMAT is correct → value-retrieval question sent instead of format-confirmation question
- Multi-statement PRESENT recorded with one source ID → FC-1 fails; verifier cannot locate assembled content
- `appetite` classified ABSENT when AMBIGUOUS-FORMAT → Task 1.3 asks a question Alex already partially answered

***

### Subtask 3 — Optional Field Coverage Analysis

**Input:** `statements[]`, manifest schema (optional fields, format rules)
**Output:** `fields[]` entries where `required: false` — same schema as Subtask 2

**Skills**
- Restraint — ABSENT with `supporting_statements: []` is a complete, correct entry
- `constraints` and `outofscope` format rule — stated by humandirector only; inference prohibited
- `referenceexamples` field recognition — brief mentions rarely labelled as such
- Conditional significance awareness — `integrationrequirements` is not low-stakes when a form is declared
- Candidate field consistency — assignments match Subtask 1 `candidate_fields[]`, not a fresh re-read

**Failure Modes**
- Inferred constraint recorded as PRESENT → FC-1 fails; no brief statement supports the value
- `outofscope` populated from absence of mention → format rule explicitly prohibits this; invented content
- `referenceexamples` not recognised as a field → design reference lost; Alex queries at Task 1.5 review
- Conditional WARNING misclassified as INFO → gap reaches Task 1.5 without Step 2 consequence surfaced

***

### Subtask 4 — Non-Mappable Statement Identification

**Input:** `statements[]`, complete `fields[].supporting_statements[]` from Subtasks 2 and 3
**Output:** `non_mappable[]` — statement_id, downstream_note (specific: names the step, consequence, and candidate field if applicable)

**Skills**
- Schema exhaustion check — explicit query of `statements[]` against all `supporting_statements[]` references; not from memory
- Downstream consequence assessment — names the step and what fails, not just "no manifest field"
- Truly non-mappable vs missed-field-mapping distinction — verify no schema field was overlooked before recording
- `schema_gap_flag` readiness — specific `downstream_note` enables Task 1.2 Subtask 4 to classify correctly

**Failure Modes**
- Schema exhaustion check skipped → `non_mappable[]` incomplete; OQ-1-11/12/13 never created
- `downstream_note` is generic ("no corresponding manifest field") → Task 1.2 cannot distinguish consequential from inconsequential; creates all or none
- Non-mappable confused with missed optional field → duplicate register entries created in Task 1.2

***

### Subtask 5 — Contradiction Detection

**Input:** `statements[]`, complete `fields[]` (for `affected_fields[]` enumeration)
**Output:** `contradictions[]` — id, statement_ids[], description (names both sides), affected_fields[]

**Skills**
- Domain knowledge of declared tech stack — some contradictions are not lexically visible
- Implicit contradiction detection — read for architectural implications, not literal content only
- Dedicated cross-statement pass — after all fields complete; single-statement reading will not surface pairs
- Non-resolution discipline — record both sides; do not choose one
- Multi-field impact enumeration — all fields the contradiction touches, not just the most obvious

**Failure Modes**
- Domain-knowledge contradiction silently resolved → no C-01 entry; constraint enters manifest without Alex's confirmation
- Implicit contradiction missed → two incompatible fields written to manifest without a human gate between them
- `affected_fields[]` incomplete → Task 1.2 creates register entries for some affected fields, not all; linked_questions connection never established
- Contradiction noted during Subtask 1 but not written to `contradictions[]` → array appears complete; Task 1.2 sees no contradiction entries; no BLOCKER auto-classified

