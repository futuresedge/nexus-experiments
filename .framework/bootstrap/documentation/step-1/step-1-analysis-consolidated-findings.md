# Step 1 Analysis — Consolidated Findings

Organised into five categories: decisions made, policy improvements, schema improvements, risks, and unresolved questions. Each finding is tagged with the task where it surfaced.

***

## 1. Decisions Made

Structural changes already agreed during this session. These are implemented — not recommendations.

| # | Decision | Replaces | Source |
|---|---|---|---|
| D-01 | Task 1.1 output is `brief-inventory.yaml` — a single structured YAML document with four arrays (`statements`, `fields`, `non_mappable`, `contradictions`) | Separate intermediate documents per subtask | Task 1.1 |
| D-02 | Task 1.1 has four subtasks, each building one array of the output document; all subtasks carry a standing read-in-full precondition | Original five subtasks with separate outputs | Task 1.1 |
| D-03 | Gap severity vocabulary: `BLOCKER / WARNING / INFO` | `BLOCKING / WARNING / LOWRISK` | Task 1.2 |
| D-04 | Terminal states: `BLOCKER:RESOLVED` and `BLOCKER:CONFIRMED-UNKNOWN` | `BLOCKINGRESOLVED` / `BLOCKINGCONFIRMEDUNKNOWN` | Task 1.2 |
| D-05 | Task 1.2 has four subtasks — required fields, optional fields, contradictions, and non-mappable statements | Three subtasks (no non-mappable path) | Task 1.2 |
| D-06 | Task 1.2 creates the open questions register (`open-questions-register.yaml`) — this IS Task 1.2's output, not a separate intermediate "gap list" | Policy referred to a "two-tier gap list" without naming it as the register | Task 1.2 |
| D-07 | Manifest artefact format: `project-manifest.yaml` and `project-manifest.traceability.yaml` | `project-manifest.md` | Task 1.4 |
| D-08 | FC-2 Gate 3 addition: a REQUIRED schema field that cannot be validly populated from the current brief is BLOCKER regardless of downstream step dependency | Gate 3 did not exist | Task 1.2 |

***

## 2. Step 1 Policy Improvements

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

## 3. Cross-Cutting Policy Improvements

Recommended changes to FC-1 through FC-9.

| # | Policy | Improvement |
|---|---|---|
| CC-01 | FC-2 | Add Gate 3 to the classification rule (already D-08 — formalise in the FC-2 document) |
| CC-02 | FC-2 | Add `POTENTIAL-CONTRADICTION` as a WARNING-level flag: contradictions requiring domain expertise to confirm are WARNING with `contradiction_flag: true`; escalated to BLOCKER if confirmed during clarification |
| CC-03 | FC-2 | Add `gap_type` as a required field in the open questions register schema: `ABSENT`, `AMBIGUOUS-INCOMPLETE`, `AMBIGUOUS-FORMAT`, `CONTRADICTION`, `SCHEMA-GAP` |
| CC-04 | FC-2 | Add `linked_questions` as a required field in the register schema (machine-readable array) |
| CC-05 | FC-2 | Add `schema_gap_flag` as an optional boolean field in the register schema, with optional `candidate_field` |
| CC-06 | FC-3 | Add instructional context rule — parenthetical retrieval instructions are permitted in questions provided they are not compound questions or decision prompts |
| CC-07 | FC-3 | Add `DECISION-REQUIRED` as a formal third response classification alongside `RESOLVED` and `CONFIRMED-UNKNOWN`. Define path: entry remains BLOCKER; decision-request record created; step enters `AWAITING-DECISION` |
| CC-08 | FC-3 | Add response format guidance: human is asked to respond per-question, referencing the question number |
| CC-09 | FC-4 | Add `approvalstatement` as a required field in Tier 1 — the human's actual words, verbatim, minimum 5 words |
| CC-10 | FC-4 | Add explicit guidance that `approvedat` records the human's action timestamp, not the executor's processing timestamp; in asynchronous workflows these must be explicitly distinguished |

***

## 4. Manifest Schema Improvements

Recommended changes to the manifest template.

| # | Improvement | Reason |
|---|---|---|
| S-01 | Add optional field `existingInfrastructure` (or `existingSetup`) | Infrastructure readiness (registered domain, existing hosting accounts, DNS control) has direct Step 2 consequences but no current schema field. Surfaced by S-13 in the case study |
| S-02 | Add optional field `successCriteria` | The human director's explicit success definition (*"live on domain, 90+ Lighthouse, contact form works, handoff-ready"*) has no schema field. Currently either lost or squeezed into `constraints` |
| S-03 | Clarify `techstack` vs `devenvironment` boundary for package managers | pnpm appeared in both `techstack` and `devenvironment` in the case study. The schema should specify whether package managers belong in one, the other, or both — and whether duplication is permitted |
| S-04 | Add scope definition for `referenceexamples` | Currently accepts named examples. The case study brief included names plus qualitative descriptors. The schema should specify whether descriptors are valid entries or overflow to non-mappable |
| S-05 | Add conditional sections table to the manifest template metadata | A lookup table mapping tech stack patterns to triggered optional sections (e.g., form handler reference → services section conditionally required; measurable performance target → performance_targets section required). Makes Subtask 2 of Task 1.2 a table lookup rather than a judgment call |
| S-06 | Change manifest format from `.md` to `.yaml` | Already D-07 — confirm in the manifest template definition |
| S-07 | Change `appetite` enum vocabulary to align with the schema documentation | The enum values (`small`, `medium`, `large`) should include their associated time range in the schema documentation to reduce the AMBIGUOUS-FORMAT gap category for this field |

***

## 5. Risks

Ordered by propagation distance — how far downstream does the failure travel before it surfaces.

### Silent failures (surface in Step 2 or later)

- **R-01** Technical contradiction (Workers vs Pages) resolved by domain knowledge rather than surfaced for human confirmation. The manifest records a deployment target that does not match the human's actual intent. Step 2's environment contract is built on a false premise. *(Task 1.1 / 1.2)*
- **R-02** `techstack` version gaps not classified as BLOCKER (Gate 1 applied without Step 2 knowledge). Step 2 either invents versions (FC-1 violation) or produces an incomplete contract. *(Task 1.2)*
- **R-03** Shadcn version not identified as a gap during Task 1.2 or 1.3. During Task 1.4 pre-drafting, the gap surfaces but is resolved by derivation with no register entry. Step 2 receives a version-derived stack entry with no provenance signal. *(Task 1.4)*
- **R-04** Non-mappable statement S-13 (Cloudflare account, DNS control) not classified in Task 1.2. Step 2 cannot confirm self-managed DNS readiness; may assume procurement is needed. *(Task 1.2)*
- **R-05** `integrationrequirements` (Formspree) classified as INFO rather than WARNING. Step 2 produces an incomplete services section with no signal that it is expected. Surfaces at Step 3 or implementation. *(Task 1.2)*

### Process integrity failures

- **R-06** Linked entries OQ-1-04 and OQ-1-05 not consolidated. Task 1.3 asks two questions about the same deployment target. Human answers inconsistently or pushes back. *(Task 1.3)*
- **R-07** OQ-1-05 (contradiction entry) not updated when OQ-1-04 is resolved. Register shows an unresolved BLOCKER contradiction despite the underlying issue being resolved. Task 1.4 reads it as still OPEN and blocks or escalates incorrectly. *(Task 1.3)*
- **R-08** `"latest stable"` written as a literal manifest value rather than flagged as a derivation requiring version resolution. Manifest violates the `techstack` format rule. *(Task 1.3 / 1.4)*
- **R-09** Traceability record written after the manifest is complete rather than field-by-field. Entries for multi-source fields (like `description`) are reconstructed from memory. FC-1 provenance cannot be independently verified. *(Task 1.4)*
- **R-10** `"looks good to me"` accepted as an explicit approval. Audit log has no defensible evidence of a deliberate human decision. FC-4 Tier 1 requirements not met. *(Task 1.5)*
- **R-11** `approvedat` recorded as executor processing timestamp rather than human response timestamp. In asynchronous workflows, this may misrepresent the timeline by hours. *(Task 1.5)*
- **R-12** Silent correction applied to an APPROVED manifest. The audit trail shows an approved document and a subsequent edit with no re-approval record — an integrity failure. *(Task 1.5)*

### Schema and quality failures

- **R-13** `appetite` field classified as non-BLOCKER (Gate 3 not applied). Task 1.3 is never triggered for it. Task 1.4 populates by inference — FC-1 violation. Manifest fails DoD 3. *(Task 1.2)*
- **R-14** Compound BLOCKER entry for `techstack` (versions, React, package manager combined). Task 1.3 asks one compound question. Human provides a paragraph answer. Task 1.4 must decompose it — reintroducing ambiguity that Task 1.1 had already resolved. *(Task 1.2)*
- **R-15** `description` field rewritten in cleaner language than the brief. The manifest is no longer a faithful restatement. Subtle editorial changes may alter scope in ways that surface as disputes during delivery. *(Task 1.4)*

***

## 6. Unresolved Questions

Items surfaced but not resolved in this session. Each is a candidate for a future policy decision or framework-level resolution.

| # | Question | Source | Where it belongs |
|---|---|---|---|
| UQ-01 | How are multi-part briefs handled? (email thread + separate notes file — which is canonical; how are conflicts between sources treated?) | Task 1.1 | Step 0 or Step 1 policy |
| UQ-02 | How is external version lookup (npm registry, GitHub releases) handled when the agent cannot make external API calls? Options: `CONFIRMED-UNKNOWN`; major-version shorthand; block until human provides. | Task 1.4 | Step 1 policy / framework tool specification |
| UQ-03 | What is the `DECISION-REQUIRED` path in full? A mid-step escalation to a human decision gate is structurally different from the clarification protocol. It implies a `AWAITING-DECISION` step state not currently in the FC-9 state machine. | Task 1.3 | FC-3 / FC-9 |
| UQ-04 | What presentation medium does the clarification exchange and the Task 1.5 review use? The medium determines what "respond with an explicit approval" looks like in practice. | Task 1.3 / 1.5 | Platform configuration or Step 1 policy |
| UQ-05 | Should correction additions (new scope introduced during the Task 1.5 correction loop) trigger a full mini Task 1.1–1.3 cycle, or a lighter-weight path? The full cycle is correct in principle but may feel disproportionate for a single added constraint. | Task 1.5 | Step 1 policy |
| UQ-06 | Does the open questions register need a terminal `ACCEPTED-AS-KNOWN-GAP` state for gaps the human director explicitly acknowledges at Step 6 but accepts without resolving? This was referenced in FC-8 but not confirmed in the register schema. | FC-8 | Open questions register schema |
| UQ-07 | Should `approvalstatement` be added to FC-4 Tier 1 as well as Tier 2? Currently Tier 2 (one-way decisions) requires it; Tier 1 (accuracy confirmations) does not. The case for adding it to Tier 1 is auditability; the case against is proportionality. | Task 1.5 | FC-4 |
| UQ-08 | The `description` field selection criteria ("include project type, primary purpose, key deliverable") were proposed here but not formally decided. Should this be codified in the manifest template or left as a skill-file instruction for the executing agent? | Task 1.4 | Manifest template or Step 1 skill file |

***

## Summary Counts

| Category | Count |
|---|---|
| Decisions made (D) | 8 |
| Step 1 policy improvements (P) | 24 |
| Cross-cutting policy improvements (CC) | 10 |
| Manifest schema improvements (S) | 7 |
| Risks identified (R) | 15 |
| Unresolved questions (UQ) | 8 |
| **Total findings** | **72** |