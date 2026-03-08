# Part 2 — Artefact Schemas

## 2.1 `brief-inventory.yaml` *(confirmed shape from Task 1.1)*

Filed at: `.framework/brief-inventory.yaml`

```yaml
statements:
  - id: S-xx
    text: "..."
    clarity: CLEAR | AMBIGUOUS
    candidate_fields: [field_name, ...]

fields:
  - field: fieldname
    required: true | false
    coverage: PRESENT | ABSENT | AMBIGUOUS-INCOMPLETE | AMBIGUOUS-FORMAT
    supporting_statements: [S-xx, ...]

non_mappable:
  - statement_id: S-xx
    downstream_note: "..."

contradictions:
  - id: C-xx
    statement_ids: [S-xx, S-xx]
    description: "..."
    affected_fields: [fieldname, ...]
```

***

## 2.2 `open-questions-register.yaml` *(created Task 1.2)*

Filed at: `.framework/open-questions-register.yaml`

```yaml
# Created: Step 1, Task 1.2
# Last modified by step: 1
# Persists through: Steps 1–6

questions:
  - questionid: OQ-{step}-{seq}         # e.g. OQ-1-01 — IMMUTABLE once set
    field: fieldname | null              # null for non-mappable/schema-gap entries
    gap_type: ABSENT
                | AMBIGUOUS-INCOMPLETE
                | AMBIGUOUS-FORMAT
                | CONTRADICTION
                | SCHEMA-GAP
    gap: "one sentence"                  # IMMUTABLE once set
    impact: "one sentence"               # names specific downstream field or DoD criterion
    source_statements: [S-xx]            # from brief-inventory.statements
    contradiction_ref: C-xx              # only for gap_type: CONTRADICTION
    classification: BLOCKER | WARNING | INFO
    linked_questions: [OQ-x-xx]          # bidirectional; populated in linking pass after Subtask 3
    schema_gap_flag: true | false        # true when no manifest field exists for this information
    candidate_field: fieldname           # when schema_gap_flag: true
    raisedbystep: 1                      # IMMUTABLE once set
    lastupdatedbystep: 1                 # mutable — updated by any step that reclassifies
    currentowner: 1                      # step currently responsible for resolution
    resolutionstatus: OPEN
                    | RESOLVED
                    | CONFIRMED-UNKNOWN
                    | DECISION-REQUIRED
                    | ACCEPTED-AS-KNOWN-GAP
    resolutionnote: null                 # populated at resolution; includes raw response and derivation notes
    resolvedbystep: null
    resolvedatexchange: null             # CE-x-xx reference
```

**Immutability rules:**
- `questionid`, `gap`, `raisedbystep` — never modified after creation
- `classification`, `currentowner`, `impact`, `lastupdatedbystep` — mutable by any subsequent step per FC-8

***

## 2.3 `CE-1-xx.yaml` — Clarification Exchange Record *(created Task 1.3)*

Filed at: `.framework/clarifications/CE-1-01.yaml`

```yaml
exchangeid: CE-{step}-{seq}              # e.g. CE-1-01
step: 1
initiatedat: "ISO 8601"                  # set at moment of delivery — NOT post-response
questions:
  - questionid: Q-CE-1-01-{seq}
    register_refs: [OQ-x-xx]            # all register entries this question covers
    field: fieldname
    gap_type: AMBIGUOUS-INCOMPLETE | AMBIGUOUS-FORMAT | CONTRADICTION
    questiontext: "..."                  # max 25 words; one sentence
    impactstatement: "..."               # one sentence
    derivation_flag: false               # true when response authorises a derivation, not a specific value
respondedat: null                        # set when Alex responds
responses:
  - questionid: Q-CE-1-01-{seq}
    responsetext: "..."                  # verbatim
    resolution: RESOLVED | CONFIRMED-UNKNOWN | DECISION-REQUIRED | UNCLEAR
    derivation_flag: true | false
    enum_mapping: value                  # when gap_type AMBIGUOUS-FORMAT
    linked_cascade: [OQ-x-xx]           # entries updated as part of linked resolution
```

***

## 2.4 `RR-1-xx.yaml` — Review Record *(created Task 1.5, new this session)*

Filed at: `.framework/reviews/RR-1-01.yaml`

Distinct from CE records — FC-4 Tier 1 artefact for human approval, not FC-3 clarification.

```yaml
reviewid: RR-{step}-{seq}
step: 1
document: .framework/project-manifest.yaml
documentstatus: DRAFT
presentedto: "Alex Chen"
presentedat: "ISO 8601"                  # set at moment of delivery
summaryvalidated: true | false           # summary-vs-manifest check passed before delivery
openquestionsincluded: [OQ-x-xx]        # all OPEN entries included in Part 2 of review package
respondedat: null
responseclassification: APPROVED | RETURNED | UNCLEAR
response: null                           # verbatim
followuprequestedat: null                # set if UNCLEAR requires follow-up
correctionapplied: null                  # CR-x-xx reference if RETURNED
auditlogentry: "actiontype-timestamp"    # reference to FC-4 audit log entry
```

***

## 2.5 `CR-1-xx.yaml` — Correction Record *(created Task 1.5, new this session)*

Filed at: `.framework/corrections/CR-1-01.yaml`

```yaml
correctionid: CR-{step}-{seq}
step: 1
task: "1.5"
receivedat: "ISO 8601"
providedby: "Alex Chen"
correctiontype: VALUE-CORRECTION | SCOPE-ADDITION
corrections:
  - field: fieldname
    previousvalue: "..."
    correctedvalue: "..."
    basis: "verbatim from Alex's response"
scopeaddition:                           # only for correctiontype: SCOPE-ADDITION
  description: "..."
  requires_mini_cycle: true | false
  mini_cycle_tasks: [1.1, 1.2, 1.3]
```

***

## 2.6 `project-manifest.traceability.yaml` *(FC-5, confirmed and extended)*

Filed at: `.framework/traceability/project-manifest.traceability.yaml`

```yaml
# Written field-by-field during drafting — NOT after
# Retained permanently after approval
# Extended sourcetypes this session:

entries:
  - outputfield: "exact field name | techstack[0] | corrections[n]"
    valuesummary: "first 30 chars of value"
    sourcetype: brief
              | clarificationanswer
              | manifestfield
              | contractfield
              | seedingresource
              | derivationrule
              | correction          # NEW — for corrections applied in Task 1.5
              | notpresentininput
    sourcereference: "specific locator"
    supersedes: "prior entry reference"  # NEW — when a correction replaces a prior value
```

**New `sourcetype` values confirmed this session:** `correction`, plus `supersedes` field for correction chains.

***

## 2.7 FC-4 Tier 1 Audit Log Entry *(confirmed and extended)*

```yaml
actiontype: documentapproved
document: .framework/project-manifest.yaml
actor: "Alex Chen"                       # named person — NOT role title
timestamp: "ISO 8601"                    # human's action timestamp — NOT executor processing time
documentversion: "DRAFT→APPROVED"
approvalstatement: "verbatim words"      # NEW — minimum 5 words, required
reviewrecord: RR-1-01
```
