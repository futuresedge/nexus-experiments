# Part 3 — Policy Improvements

Organised by task. Each entry includes: ID, description, classification (NEW vs CONFIRMED from prior sessions), and which policy document it affects.

***


## From session 1:

Recommended changes to the Step 1 policy document, by task.

### Task 1.1

- **P-01** Add a `gap_type` field to the `fields` array in `brief-inventory.yaml`: `ABSENT`, `AMBIGUOUS-INCOMPLETE` (partial information), `AMBIGUOUS-FORMAT` (information present but wrong form). This distinction propagates to Task 1.3 question formulation — absent fields require *"what is your X?"*; format-ambiguous fields require *"you said X — which valid value best matches?"*
- **P-02** Specify that contradiction detection must scan across all sections of the brief, not only between required fields — contradictions can span required and optional sections.
- **P-03** Add a `POTENTIAL-CONTRADICTION` classification for contradictions that can only be confirmed with domain expertise. Classified as WARNING with a `contradiction_flag: true` annotation. Escalated to BLOCKER if confirmed during clarification. (See also FC-2 improvement below.)

### Task 1.2

- **P-04** Add explicit instruction that Gate 1 requires the executor to have loaded Step 2 and Step 3 policy documents as reference material. Without this, Gate 1 is guesswork. State this as a required input to Task 1.2.
- **P-05** Add `linked_questions` as a required field in the open questions register schema — a machine-readable array, not just a text note. Task 1.3 queries this field directly to detect consolidation opportunities.
- **P-06** Add `schema_gap_flag: true` as an optional field in the register for WARNING entries that represent missing manifest schema fields. Creates a feedback loop for manifest template evolution.
- **P-07** Add Subtask 4 (non-mappable classification) explicitly to the Task 1.2 policy definition. Currently absent — non-mappable statements have no classification path and silently disappear.

### Task 1.3

- **P-08** Add response classification as the first operation of Subtask 3 — before updating any register entry, classify each response as `RESOLVED`, `CONFIRMED-UNKNOWN`, or `DECISION-REQUIRED`. Define `DECISION-REQUIRED` path: entry remains BLOCKER, a decision-request record is created, step enters `AWAITING-DECISION` state.
- **P-09** Add instructional context rule to question formulation: a question may include a parenthetical command or reference that enables the human to retrieve the information (e.g., `run node --version`), provided it does not constitute a compound question or decision prompt.
- **P-10** Add linked entry propagation as an explicit step in Subtask 3: *"For each RESOLVED entry, query the register for all entries referencing this entry's `questionid` in their `linked_questions` field and apply the same resolution."*
- **P-11** Add a note that `resolutionnote` values may require mapping to valid enum values. This mapping is a named derivation — not invention — and must be recorded in the traceability record. Specifically: *"latest stable"* and equivalent deferred version references are valid RESOLVED responses but require a version-resolution derivation step at Task 1.4; the `resolutionnote` must flag this explicitly.
- **P-12** Specify the expected response format for the clarification exchange: human is asked to respond per-question, referencing the question number. This is guidance for processability, not a constraint on how the human writes.

### Task 1.4

- **P-13** Add Subtask 1 (Pre-Drafting Derivation Resolution) as the first explicit subtask: before any field is written, the executor reads all register entries for `resolutionnote` derivation flags and resolves them. Version lookups happen here, not during field population.
- **P-14** Add new gap detection during pre-drafting as an explicit instruction: if a field has no valid source during derivation resolution, a new register entry is created before drafting begins. Task 1.4 is a quality gate that catches Task 1.2 omissions.
- **P-15** Add selection criteria for `description` field assembly: *"Include project type, primary purpose, and key deliverable. Exclude constraints, deployment details, and named actors — these have dedicated fields."* Without this, two executors produce different descriptions from the same brief.
- **P-16** Clarify that the self-check runs before `status: DRAFT` is set — not after. Status DRAFT is the executor's assertion of completeness; setting it before the check inverts the purpose of the check.
- **P-17** Add re-check scope rule for the correction loop in Task 1.5: after a correction, the self-check re-runs against changed fields and any fields that depend on them — not the full check unless a structurally significant field changed.

### Task 1.5

- **P-18** Add summary generation with a deterministic rendering rule and a summary-vs-manifest validation check: every summary field value must match the corresponding manifest field exactly.
- **P-19** Add `UNCLEAR` as a third response classification alongside `APPROVED` and `RETURNED`. Define handling: identify the specific question that resolves the ambiguity; re-present with that question; `presentedat` timestamp does not change.
- **P-20** Define minimum explicit approval statement: the response must name the document and contain the word "approved" (case-insensitive). Freeform affirmation alone is insufficient.
- **P-21** Add a scope addition path for the correction loop: corrections that introduce new content (not corrections to existing values) are separated from value corrections and processed via a lightweight Task 1.1–1.3 mini-cycle before the manifest is updated.
- **P-22** Add a correction loop health check: if the same field is corrected twice, the executor flags it as `UNSTABLE-FIELD` and requests the human director make a single definitive statement before re-presenting.
- **P-23** Add a loop escalation trigger: after three cycles without approval, the executor explicitly surfaces the loop pattern to the human director rather than continuing silently.
- **P-24** Reference the audit log specification by path rather than defining the entry format inline — prevents the Task 1.5 entry format drifting from the canonical audit log schema.

***

From session 2:

## Task 1.2 — Gap Classification

| ID | Description | Type | Affects |
|---|---|---|---|
| **P-04** | Task 1.2 policy must explicitly state the executor must have loaded Step 2 and Step 3 policy documents as reference material before applying Gate 1. Gate 1 is not guesswork — it requires knowledge of what each downstream step needs per field. | CONFIRMED | Task 1.2 policy |
| **P-01** | Add `gap_type` as a required field in the open-questions register schema. Values: `ABSENT`, `AMBIGUOUS-INCOMPLETE`, `AMBIGUOUS-FORMAT`, `CONTRADICTION`, `SCHEMA-GAP`. Distinguishes gap character upstream, shapes question formulation in Task 1.3 without re-derivation. | CONFIRMED | Register schema, FC-8 |
| **S-05** | Add a conditional sections table to the manifest template metadata. Maps tech stack patterns to triggered optional manifest sections (e.g. form handler reference → `integrationrequirements` conditionally required). Makes Subtask 2 a table lookup, not a judgment call. | CONFIRMED | Manifest template |
| **P-Subtask2-01** | The Done condition for Task 1.2 Subtask 2 must require explicit confirmation that every optional field was assessed — not just that entries were created for the ones that triggered classification. Silent skipping of ABSENT optional fields with "no impact" produces a register that appears complete but is not. | NEW | Task 1.2 policy, DoD |
| **P-07** | Add Subtask 4 (non-mappable statement classification) explicitly to the Task 1.2 policy. Currently absent. Non-mappable statements with downstream consequences must not disappear after Task 1.1. | CONFIRMED | Task 1.2 policy |
| **P-Subtask4-01** | The Done condition for Task 1.2 Subtask 4 must require the executor to confirm explicitly that every entry in `non_mappable[]` was assessed — either producing a register entry or recording a documented no-entry decision. Silent skipping is not detectable without this requirement. | NEW | Task 1.2 policy, DoD |
| **CC-05** | Add `schema_gap_flag` (boolean) and `candidate_field` (string) as optional register fields. `schema_gap_flag: true` creates a structured feedback loop for manifest template evolution. Without the flag, schema gaps are in the register but produce no signal for template improvement. | CONFIRMED | Register schema, FC-8 |
| **P-Linking-01** | The bidirectional `linked_questions` linking pass must be an explicit named step at the end of Task 1.2 Subtask 3 (not implied). Procedure: for each register entry, query all entries referencing its `questionid` in their `linked_questions` field; set linkages bidirectionally. | NEW | Task 1.2 policy, Subtask 3 |
| **P-03** | Add `POTENTIAL-CONTRADICTION` as a WARNING-level flag for contradictions that require domain expertise to confirm. Enters the register with `contradiction_flag: true`, escalated to BLOCKER if confirmed during clarification. Prevents domain-knowledge-dependent contradictions from being silently missed. | CONFIRMED | FC-2, Register schema |

***

## Task 1.3 — Clarification Resolution

| ID | Description | Type | Affects |
|---|---|---|---|
| **P-09** | Instructional context rule for question formulation: parenthetical retrieval instructions are permitted in questions (e.g. "Run `node --version` to check") provided they are not compound questions or decision prompts. Without this rule, Q6 for Node.js version is almost certain to produce `CONFIRMED-UNKNOWN` from a human who could find the answer with one command. | CONFIRMED | FC-3, Task 1.3 policy |
| **P-Subtask1-01** | Formalise the `gap_type` → question type mapping in Task 1.3 policy. `AMBIGUOUS-INCOMPLETE` → value-retrieval question; `AMBIGUOUS-FORMAT` → choice-based question presenting valid options; `CONTRADICTION` → disambiguation question naming both interpretations. Makes question formulation deterministic rather than a judgment call. | NEW | Task 1.3 policy, FC-3 |
| **P-Subtask1-02** | The exchange record shell must be created and filed before delivery. `initiatedat` is set at the moment of sending — these are the same moment. Any gap between record creation and delivery is an audit integrity issue. The policy must state this explicitly. | NEW | Task 1.3 policy, FC-3 |
| **P-Subtask1-03** | Clarify the apparent tension in the policy between "one question per item, not a consolidated list" and "all blocking gaps in one batch exchange." These are not contradictory. Correct statement: *"One question per gap — each gap produces exactly one question — all questions delivered in a single batch exchange."* Current wording allows misreading. | NEW | Task 1.3 policy, FC-3 |
| **P-08** | Response classification (`RESOLVED` / `CONFIRMED-UNKNOWN` / `DECISION-REQUIRED` / `UNCLEAR`) must be a formal, named first step of Task 1.3 Subtask 3 — before any register update. Classify before act is the invariant. | CONFIRMED | Task 1.3 policy |
| **P-10** | Linked entry propagation must be an explicit named step in Task 1.3 Subtask 3: "For each RESOLVED entry, query the register for all entries with this entry's `questionid` in their `linked_questions` field and apply the same resolution, citing the same exchange reference." Without this, a resolved contradiction leaves its linked ambiguity entry in OPEN status. | CONFIRMED | Task 1.3 policy |
| **P-11** | "Latest stable" and equivalent deferred version references are valid `RESOLVED` responses but require `derivation_flag: true` in the exchange record and an explicit derivation note in `resolutionnote`. Task 1.4 must not treat these as final values — they require version resolution before field population. | CONFIRMED | Task 1.3 policy, Task 1.4 policy |
| **P-Subtask3-01** | Define `UNCLEAR` response handling: identify the single follow-up question that resolves the ambiguity; re-present to Alex; `initiatedat` timestamp of the original exchange does not change; a `followuprequestedat` timestamp is added to the exchange record. | NEW | Task 1.3 policy |
| **P-Subtask3-02** | Define `DECISION-REQUIRED` response handling in full: entry remains BLOCKER, process enters `AWAITING-DECISION` state, a decision-request note is created. This is not a clarification exchange — FC-3 does not cover undecided information. Undecided technical choices require explicit framework support outside FC-3. Flag as UQ-03. | NEW | Task 1.3 policy, FC-3 |

***

## Task 1.4 — Manifest Drafting

| ID | Description | Type | Affects |
|---|---|---|---|
| **P-13** | Add pre-drafting derivation resolution as an explicit Subtask 1 in Task 1.4. Before any manifest field is written: query `CE-1-xx.yaml` for `derivation_flag: true` entries; resolve each to a specific value; record in the traceability record with `sourcetype: derivationrule`. Only then begin field population. | CONFIRMED | Task 1.4 policy |
| **P-Subtask1-PreDraft-01** | The policy must specify handling when version lookup is unavailable during pre-drafting resolution: the value becomes `CONFIRMED-UNKNOWN`, the register entry is updated to reflect this, and the field is written as empty with an `openquestions` entry. Guessing a version number is not a fallback. | NEW | Task 1.4 policy |
| **P-15** | Add selection criteria for `description` field assembly to the policy: include project type, primary purpose, key deliverable. Exclude constraints, deployment details, and named actors — these have dedicated fields. Every sentence must trace to a brief statement. The executor's voice does not appear. | CONFIRMED | Task 1.4 policy |
| **P-Subtask2-01** | Version-less `techstack` entries discovered during field population (e.g. `pnpm` version not confirmed) are treated the same as pre-drafting derivations: pause field population, create a register entry, resolve via derivation, then write. The pre-drafting step may not have caught every derivation-dependent field. | NEW | Task 1.4 policy |
| **S-03** | Clarify in the manifest schema whether package managers belong in `techstack`, `devenvironment.packagemanager`, or both. Confirmed decision (DQ-06): duplication is permitted and intentional. The schema should document this explicitly so it is not interpreted as an error by a verifier. | CONFIRMED | Manifest schema |
| **P-Subtask3-01** | Add an explicit rule that AMBIGUOUS optional fields are recorded with the ambiguity and a register cross-reference — not as confirmed values and not as empty fields. The `integrationrequirements` case (tentative Formspree) is the model: record what was said, note it is tentative, reference the open question ID. | NEW | Task 1.4 policy |

***

## Task 1.5 — Human Review

| ID | Description | Type | Affects |
|---|---|---|---|
| **P-18** | Summary generation rule: the review package summary is generated deterministically from the manifest. Before delivery, every summary value is validated against its corresponding manifest field. A rendering error means Alex approves a summary that doesn't match the canonical document. Validation is a required step. | CONFIRMED | Task 1.5 policy |
| **P-Subtask1-1.5-01** | The review instruction must explicitly name what a returned correction looks like: *"identify the specific field and the correct value."* Without this, Alex may return a correction as a vague statement that cannot be classified as `RETURNED` without a follow-up. | NEW | Task 1.5 policy |
| **P-19** | Add `UNCLEAR` as a formal third response classification in Task 1.5 Subtask 3, with a defined follow-up path. Matches the pattern established in Task 1.3. Examples of `UNCLEAR`: *"Looks good to me"*, *"Mostly right but not sure about the tech stack."* | CONFIRMED | Task 1.5 policy |
| **P-20** | Define minimum explicit approval statement for FC-4 Tier 1. The response must: name the document (or be unambiguously in the context of the review), and contain a deliberate affirmation — "approved," "confirmed," "yes, that's correct" are valid. "Fine," "sure," "looks good" are not sufficient. This is a policy definition, not a judgment call. | CONFIRMED | Task 1.5 policy, FC-4 |
| **P-Subtask3-1.5-01** | Add scope change detection to the `RETURNED` classification. If a correction modifies a field whose value was used to resolve a prior BLOCKER register entry, the executor must check whether the correction invalidates that resolution before applying it. Example: removing the static constraint re-opens the Workers/Pages question (OQ-1-10). This is a targeted register check, not a full Task 1.2 re-run. | NEW | Task 1.5 policy |
| **P-21** | Add a scope addition path for Task 1.5 corrections. Corrections that introduce new content (not a value change to an existing field) are separated from value corrections and processed via a lightweight Task 1.1–1.3 mini-cycle before the manifest is updated. | CONFIRMED | Task 1.5 policy |
| **P-22** | Add `UNSTABLE-FIELD` flag after the same field is returned for correction twice in the same Task 1.5 loop. When triggered: request a definitive statement from Alex on that specific field before re-presenting the full manifest. | CONFIRMED | Task 1.5 policy |
| **P-23** | Add loop escalation trigger after three Task 1.5 correction cycles without approval. When triggered: surface the loop pattern explicitly to Alex; ask what is preventing approval. Do not continue silent cycling. | CONFIRMED | Task 1.5 policy |
| **P-Subtask4-1.5-01** | Change summary is a required element of every re-presentation after a correction — not optional. Format: names the field, the previous value, and the corrected value. Allows Alex to confirm the correction was applied correctly without re-reading unchanged content. | NEW | Task 1.5 policy |
| **CC-09** | Add `approvalstatement` as a required field in FC-4 Tier 1 audit log entries. Contains Alex's verbatim approval words. Minimum 5 words. This is the evidence of a deliberate decision — a status field alone is a state indicator, not proof. | CONFIRMED | FC-4 |
| **CC-10** | `approvedat` must record the human's action timestamp — the datetime of Alex's response — not the executor's processing timestamp. In asynchronous workflows these may differ significantly. The policy must make this distinction explicit and require the human's timestamp. | CONFIRMED | FC-4, Task 1.5 policy |
| **P-Subtask5-1.5-01** | Extend the post-approval immutability rule to the companion traceability record. Once `status: APPROVED` is set, neither `project-manifest.yaml` nor `project-manifest.traceability.yaml` may be modified. Any post-approval correction requires returning to DRAFT and completing a full Task 1.5 re-run. | NEW | Task 1.5 policy, FC-1, FC-5 |

