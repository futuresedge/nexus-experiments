# Task 1 Skills and Failure Modes Analysis

***

## Task 1.1 — Brief Inventory: Skills by Subtask

**The question Task 1.1 answers:** *What is in the brief, and does it map to the required schema?*

**Output structure:** `brief-inventory.yaml` — four arrays: `statements[]`, `fields[]`, `non_mappable[]`, `contradictions[]`

**The subtask sequence is dependency-ordered.** Subtask 1 (full read) must complete before any other subtask begins. Subtask 2 (statement extraction) before Subtask 3 (required fields) — because field coverage is assessed against extracted statements, not against the raw brief directly. Subtasks 5 and 6 (non-mappable and contradictions) run after Subtask 4 (optional fields) — both require a complete field coverage picture before they can be assessed reliably.

***

### Subtask 1 — Full Brief Read

**Question:** What does this brief contain as a whole?

**No classification happens in this subtask.** The executor reads the entire brief before writing a single entry. This is not administrative — it is the operational application of L5. 

#### Skills Required

- **Read-before-classify discipline.** The executor must not begin populating `statements[]` during the read. The risk of classifying mid-read is anchoring: an early statement that appears unambiguous may only reveal its ambiguity in light of a later statement. If Subtask 2 begins before the full brief is read, the executor may classify S-01 as CLEAR and miss that S-08 contradicts it.

- **Tension flagging without resolution.** During the read, the executor notes apparent tensions, contradictions, and non-mappable content for later subtasks — without resolving them. Resolution is Subtask 6's job. A read that produces internal resolutions (*"these two things seem inconsistent but probably mean X"*) silently eliminates the evidence that Subtask 6 needs to produce a `contradictions[]` entry.

- **Brief completeness assessment.** Before Subtask 2 begins, the executor forms a structural picture: does the brief appear to contain tech stack information at all? Does it mention deployment? This prevents a Subtask 3 failure mode where a field is classified ABSENT because the executor stopped reading too early and missed a late-brief statement.

#### Failure Modes

- **Premature classification.** The executor begins writing `statements[]` during the read. An ambiguity discovered at S-10 cannot retroactively change the clarity classification assigned to S-02 if the subtask boundary has already been crossed.
- **Tension resolved during read.** The executor reads S-04 (*"Cloudflare Workers"*) and S-11 (*"fully static"*), internally resolves the tension using domain knowledge, and does not flag it for Subtask 6. The `contradictions[]` array is empty where it should contain `C-01`.

***

### Subtask 2 — Statement Extraction and Clarity Classification

**Question:** What are the discrete statements in the brief, and is each one unambiguous?

**Output:** `statements[]` — each entry: `id`, `text`, `clarity` (CLEAR | AMBIGUOUS), `candidate_fields[]`

#### Skills Required

- **Statement atomisation.** A brief sentence may contain two statements. *"I need a static site deployed to Cloudflare using AstroJS"* contains three statements: (1) static output mode, (2) Cloudflare deployment, (3) AstroJS tech stack. Each requires its own `statements[]` entry. An executor who records this as a single S-01 with three candidate fields produces a register downstream that cannot independently trace each value to a specific statement — it can only trace to *"a sentence that mentioned all three."*

- **Clarity classification precision.** `AMBIGUOUS` does not mean *"I am uncertain."* It means *"this statement could be interpreted to produce different field values depending on interpretation, and both interpretations are plausible from the brief alone."* The executor must be able to name at least two competing interpretations before assigning AMBIGUOUS. A statement is CLEAR if a single reading produces the field value unambiguously.

- **Candidate field assignment from schema knowledge.** `candidate_fields[]` entries must be real manifest field names — not descriptions, not paraphrases. *"The tech stack"* is not a valid `candidate_fields` entry. *"techstack"* is. This requires the executor to have the manifest schema loaded before Subtask 2 begins. A statement assigned `candidate_fields: []` is a non-mappable statement — it should be left for Subtask 5, not recorded as an entry with an empty array.

- **Implicit statement recognition.** Some brief statements make implicit claims. *"Shadcn/ui requires React"* is a statement about tech stack (explicit: Shadcn/ui; implicit: React). The implicit claim must produce its own statement entry — not be absorbed into the explicit one — because its `clarity` classification may differ from the parent statement. The `@astrojs/react` case from Task 1.4 demonstrates the cost of missing this at Subtask 2: the implicit dependency was not surfaced until manifest drafting. 

- **Verbatim extraction discipline.** `text` is the statement as it appears in the brief — not paraphrased, not normalised. The executor's editorial voice must not appear in the `statements[]` array. If the brief says *"I want it to feel clean and minimal"*, `text` is that sentence. It is not *"visual style preference: clean, minimal."*

#### Failure Modes

- **Compound statement recorded as one.** S-01 says *"AstroJS with Shadcn/ui and React for component interactivity."* Recorded as one entry with `candidate_fields: [techstack]`. Task 1.2 Subtask 1 later struggles to create separate register entries for AstroJS, Shadcn/ui, and React because they share a single source statement — the source reference for each field is identical rather than specific.

- **AMBIGUOUS assigned without naming two interpretations.** The executor marks *"Cloudflare Workers or Pages"* as AMBIGUOUS — correct. But assigns it a single `candidate_field: deploymenttarget`. Task 1.2 cannot determine from this entry whether the ambiguity is format-based (two names for the same thing) or content-based (two genuinely different products). The `gap_type` in the register (AMBIGUOUS-FORMAT vs AMBIGUOUS-INCOMPLETE) is not derivable from the `brief-inventory.yaml` entry alone.

- **Implicit statement missed.** React confirmed via *"Shadcn/ui requires React"* but no separate `statements[]` entry created for React. Task 1.2 Subtask 1 sees no explicit statement for React → classifies `techstack` as ABSENT for React → creates OQ-1-03 as ABSENT rather than AMBIGUOUS-INCOMPLETE. The question asked is *"Is React required?"* rather than *"The brief implies React — please confirm."* Two different questions producing two different register entries. 

***

### Subtask 3 — Required Field Coverage Mapping

**Question:** Does the brief contain sufficient information to populate each required manifest field?

**Output:** `fields[]` entries for required fields — each: `field`, `required: true`, `coverage` (PRESENT | ABSENT | AMBIGUOUS-INCOMPLETE | AMBIGUOUS-FORMAT), `supporting_statements[]`

#### Skills Required

- **Coverage classification precision — PRESENT means sufficient to populate, not merely mentioned.** A brief that says *"we'll be using the latest AstroJS"* mentions AstroJS but does not provide sufficient information to populate `techstack` per its format rule (*"named technologies only — AstroJS 5.x is valid, modern frontend stack is not"*). The field is AMBIGUOUS-INCOMPLETE, not PRESENT. The executor must test coverage against format rules, not just against field names. 

- **Format rule knowledge per field.** The manifest schema's format rules are not all identical. `appetite` has valid enum values; `techstack` has a named-technology rule; `deploymenttarget` requires a named provider. Each field's coverage classification must be tested against its own format rule, not a generic "does information exist" test. An executor without format rule knowledge produces PRESENT classifications that Task 1.4 later rejects at the self-check step.

- **Multi-statement assembly detection.** A required field may have PRESENT coverage only when two or more statements are combined. `description` often draws from three or four brief statements. The executor must recognise when PRESENT coverage is assembled rather than stated directly — because assembled fields have a different traceability shape: `supporting_statements: [S-01, S-06, S-07]` rather than `supporting_statements: [S-01]`. This distinction directly informs Task 1.4's description assembly rule. 

- **`humanactors` completeness check.** This field has a structural requirement: at least one `humandirector` entry must exist. PRESENT coverage means both *"a human actor is mentioned"* and *"their role is identifiable as humandirector."* A brief that names Alex as the project contact but never makes the humandirector role unambiguous is AMBIGUOUS-INCOMPLETE for `humanactors` — not PRESENT.

- **`appetite` enum awareness.** The `appetite` field has three valid values: `small`, `medium`, `large`. A brief that says *"I want this done quickly"* is ABSENT — no mappable value. A brief that says *"a couple of weeks"* is AMBIGUOUS-FORMAT — a duration is present but not in enum form. The executor must know the enum before classifying this field.

- **Step 2 and Step 3 downstream awareness.** The executor does not apply Gate 1 in Task 1.1 — that is Task 1.2's job. But awareness of what downstream steps require per field shapes the precision of PRESENT vs AMBIGUOUS-INCOMPLETE classification. A field that Task 1.2 will almost certainly classify BLOCKER deserves a more precise coverage assessment than a field unlikely to have BLOCKER consequences. This is not a formal requirement — it is a quality-of-output competency.

#### Failure Modes

- **PRESENT assigned for mentioned-but-insufficient values.** `techstack` classified PRESENT because the brief mentions *"AstroJS, the latest version."* Task 1.2 passes over it. Task 1.4 pre-drafting step discovers `derivation_flag` is needed and creates OQ-1-01 retroactively. The register entry should have been created in Task 1.2 from a Task 1.1 AMBIGUOUS-INCOMPLETE classification. 

- **`appetite` classified ABSENT when it is AMBIGUOUS-FORMAT.** *"A few days of focused work"* is not ABSENT — it is a duration that requires mapping to a valid enum value. If classified ABSENT, Task 1.2 creates a register entry asking *"what is the project appetite?"* — a question Alex already partially answered. The correct question (and question type) is different: *"Your timeline of a few days maps to 'small' — can you confirm?"*

- **Multi-statement PRESENT not recorded.** `description` is classified PRESENT with `supporting_statements: [S-01]`. But S-01 only provides the project type and name. S-06 provides the page sections. S-07 provides the visual style. Task 1.4's description assembly produces a value with a traceability entry citing only S-01 — and a verifier checking the assembled description against the stated source cannot find the sections or visual style referenced in S-01 alone. FC-1 fails.

***

### Subtask 4 — Optional Field Coverage Mapping

**Question:** Does the brief contain information relevant to each optional manifest field?

**Output:** `fields[]` entries for optional fields — each: `field`, `required: false`, `coverage`, `supporting_statements[]`

#### Skills Required

- **Restraint — ABSENT is a valid, complete classification.** Optional fields absent from the brief are recorded as ABSENT and left empty. The executor must not populate them with reasonable assumptions. *"No existing assets mentioned — probably doesn't have any"* is not a basis for a PRESENT classification. ABSENT is the complete, correct entry. The assumption temptation is stronger for optional fields than required ones, precisely because the stakes feel lower. 

- **Distinguishing ABSENT from information that would belong in a different field.** A brief that says *"I'll need to hand this off to a developer later"* is not providing `existingassets` information. It may be providing `constraints` information, or non-mappable content. The executor must resist the urge to re-map statements from Subtask 2 to optional fields they don't quite fit. The candidate field assignment from Subtask 2 is the canonical mapping — optional field coverage mapping tests against it, not against a fresh reading.

- **`constraints` and `outofscope` specificity requirement.** These fields have explicit format rules: *"only constraints explicitly stated by humandirector — do not infer from the tech stack"* and *"only what humandirector explicitly excluded — absence of mention ≠ out of scope."*  An executor who marks `constraints` as PRESENT because the tech stack implies certain limitations produces a field value in Task 1.4 that violates the format rule. The coverage classification must test against the format rule: is there an explicit statement of a constraint, or is the constraint inferred? 

- **`referenceexamples` recognition.** This optional field is easy to miss because reference examples in briefs are rarely labelled as such. *"I like how Linear.app looks"* is a `referenceexamples` statement. An executor without schema awareness of this field's existence will classify this as non-mappable in Subtask 5. The field must be in the executor's schema vocabulary before Subtask 4 begins.

- **Conditional requirement awareness.** Some optional fields become effectively required in certain contexts. `integrationrequirements` is optional by schema but becomes a WARNING-level gap (not INFO) when a contact form is declared in the brief — because the form handler is a downstream dependency. The executor does not classify severity in Task 1.1, but identifying that *"optional"* doesn't mean *"low stakes"* improves the coverage classification precision.

#### Failure Modes

- **Inferred constraint recorded as PRESENT.** The brief declares AstroJS. The executor infers *"no server-side rendering"* as a constraint of AstroJS's default static output mode and records `constraints` as PRESENT. Task 1.4 populates `constraints` with inferred content. FC-1 fails — the traceability entry cites no brief statement because Alex never stated the constraint. 

- **`referenceexamples` not recognised.** *"I want it to feel like Linear.app"* is classified as non-mappable style preference in Subtask 5. Task 1.2 does not create a register entry for `referenceexamples` because the field shows ABSENT. Task 1.4 produces a manifest with an empty `referenceexamples` field. Alex reviews and says *"I mentioned Linear.app — why isn't that in there?"* The gap traces to a missed classification in Subtask 4.

- **`outofscope` populated from absence.** Alex never mentions a CMS. The executor records `outofscope: [CMS]` because it is a common exclusion. Task 1.4 writes *"CMS"* into the `outofscope` field. FC-1 fails — Alex never said CMS was out of scope; the executor invented an exclusion from an absence of mention, which the format rule explicitly prohibits. 

***

### Subtask 5 — Non-Mappable Statement Identification

**Question:** Which brief statements don't map to any manifest field, and do they carry downstream consequences?

**Output:** `non_mappable[]` — each: `statement_id`, `downstream_note`

#### Skills Required

- **Schema exhaustion check.** After Subtasks 3 and 4, every statement in `statements[]` that has at least one entry in `supporting_statements[]` across the `fields[]` array is accounted for. Non-mappable statements are those that appear in no `supporting_statements[]` reference. The executor must run this check explicitly — not rely on memory of which statements felt relevant during Subtasks 3 and 4.

- **Downstream consequence assessment.** Not all non-mappable statements are inconsequential. A statement like *"I already have a Cloudflare account set up"* maps to no manifest field but carries a Step 2 infrastructure consequence. The `downstream_note` must identify this consequence specifically — not record *"no manifest field."* The note *"Infrastructure readiness — no manifest field exists; Step 2 deployment section may assume account procurement is required if this is not surfaced"* is a complete entry. *"Does not map to schema"* is not.

- **Distinguishing truly non-mappable from missed-field-mapping.** Before recording a statement as non-mappable, the executor must confirm it does not map to a field that was missed in Subtasks 3 or 4. A statement that maps to an existing optional field the executor didn't consider is not non-mappable — it is an ABSENT classification that should be corrected. Non-mappable is reserved for statements where no manifest field exists for the content type.

- **`schema_gap_flag` awareness.** Non-mappable statements that carry genuine downstream consequences are candidates for `schema_gap_flag: true` in the Task 1.2 register. The executor does not set this flag in Task 1.1 — that is Task 1.2 Subtask 4's work — but the `downstream_note` quality directly determines whether Task 1.2 can make that classification correctly. A vague note produces a vague register entry. A specific note produces a specific register entry.

#### Failure Modes

- **Schema exhaustion check not run.** The executor identifies non-mappable statements during the read (Subtask 1) and relies on that memory. Two statements that felt irrelevant during reading are not recorded. Task 1.2 Subtask 4 receives a `non_mappable[]` array that is incomplete — no entry for the Cloudflare account statement. OQ-1-11 is never created. 

- **`downstream_note` is generic.** Every non-mappable entry reads *"No corresponding manifest field."* Task 1.2 Subtask 4 processes each entry and cannot determine which ones warrant register entries versus which are genuinely inconsequential. The executor either creates register entries for all of them (register noise) or none of them (missed gaps). Both outcomes stem from a `downstream_note` that provided no signal.

- **Non-mappable confused with optional-field-absent.** *"I have a Cloudflare account"* is recorded as non-mappable. In fact, `deploymenttarget` has a `supporting_statements` entry and the account statement was simply not considered during Subtask 3. The non-mappable entry creates a duplicate path: Task 1.2 Subtask 1 creates a register entry for `deploymenttarget` from the AMBIGUOUS-INCOMPLETE classification, and Task 1.2 Subtask 4 creates a second register entry from the non-mappable note — both about the same underlying information.

***

### Subtask 6 — Contradiction Detection

**Question:** Do any brief statements contradict each other, directly or by implication?

**Output:** `contradictions[]` — each: `id`, `statement_ids[]`, `description`, `affected_fields[]`

#### Skills Required

- **Domain knowledge of the declared tech stack.** Some contradictions are only visible to an executor who knows the technology. *"Cloudflare Workers"* and *"fully static output"* are not lexically contradictory — Cloudflare Workers is a server runtime, and static output means no server-side rendering. Without knowing that, the executor sees two statements about Cloudflare and does not flag a contradiction.  Domain knowledge is a prerequisite skill for this subtask — it cannot be replaced by policy compliance alone. 

- **Implicit contradiction detection.** Contradictions are not always stated directly. *"No server-side rendering"* (explicit constraint) and *"contact form with server validation"* (implied requirement) contradict each other without using contradictory words. The executor must read for what each statement *implies* about the architecture, not just what it explicitly states.

- **Cross-statement reading discipline.** Contradictions require at least two statements to be read simultaneously. Single-statement reading — the default mode during Subtask 2 — will not surface them. The executor must make a dedicated pass over the full `statements[]` array specifically looking for cross-statement tensions, after Subtask 2 has made all implicit content explicit.

- **Non-resolution discipline.** The executor must record the contradiction without resolving it. This is the hardest skill in this subtask. An executor with domain knowledge will often have a strong intuition about which side of a contradiction is correct. That intuition must not produce a silent resolution — it must produce a `contradictions[]` entry with a specific `description` that names both sides. Task 1.3 is where the resolution happens, with Alex's input. 

- **Multi-field impact enumeration.** A single contradiction may affect more than one manifest field. The Workers/Pages contradiction affects `deploymenttarget` (which product?) and potentially `constraints` (is the static constraint still valid?). `affected_fields[]` must enumerate all fields the contradiction touches — not just the most obvious one. An incomplete `affected_fields[]` means Task 1.2 creates register entries for some affected fields but not others.

#### Failure Modes

- **Domain-knowledge-dependent contradiction silently resolved.** The executor sees *"Cloudflare Workers"* and *"fully static"*, knows Workers is a server runtime, concludes the human probably meant Cloudflare Pages, and records `deploymenttarget` as AMBIGUOUS-INCOMPLETE (not PRESENT) without a `contradictions[]` entry. Task 1.2 treats this as a single gap — asks *"Which Cloudflare product?"* — and Alex confirms Pages. The static constraint contradiction is never explicitly surfaced. The constraint stays in the manifest unchallenged. 

- **Implicit contradiction missed.** No statement says *"no server-side rendering"* explicitly, but the tech stack (AstroJS, static output) implies it. The contact form handler requirement implies a POST endpoint. The executor, finding no explicit constraint statement, misses the implicit tension. Task 1.3 never asks about it. Task 1.4 records `constraints: [fullyStatic]` from the AstroJS inference and `integrationrequirements: [formHandler]` — and no one has confirmed these are compatible in Alex's understanding.

- **`affected_fields[]` incomplete.** The Workers/Pages contradiction is recorded with `affected_fields: [deploymenttarget]`. Task 1.2 creates OQ-1-05 for `deploymenttarget`. The static constraint (`constraints`) is not listed. OQ-1-10 is created in Task 1.2 Subtask 1 from the `constraints` field coverage analysis — but its link to OQ-1-05 is not established because the `contradictions[]` entry didn't connect them. The bidirectional linking pass in Task 1.2 must reconstruct a connection that Task 1.1 should have made explicit.

***

## Summary — Skills Compendium for Task 1.1

| Subtask | Critical skill | Most consequential failure |
|---|---|---|
| 1 — Full read | Read-before-classify discipline | Implicit contradiction silently resolved during read |
| 2 — Statement extraction | Statement atomisation; implicit statement recognition | Compound statements collapsed; implicit dependency missed |
| 3 — Required field coverage | Format-rule knowledge per field; multi-statement assembly detection | PRESENT assigned for format-non-compliant values |
| 4 — Optional field coverage | Restraint (ABSENT is complete); `constraints`/`outofscope` format rule knowledge | Inferred constraints recorded as PRESENT |
| 5 — Non-mappable identification | Schema exhaustion check; downstream consequence assessment | Non-mappable array incomplete; vague `downstream_note` |
| 6 — Contradiction detection | Domain knowledge; non-resolution discipline; multi-field impact enumeration | Domain-knowledge contradiction silently resolved |

**One skill appears across all six subtasks and is the most foundational prerequisite for Task 1.1:** full manifest schema knowledge — required field names, optional field names, format rules per field, and valid enum values. An executor without this loaded before Subtask 2 begins cannot reliably classify coverage, identify candidate fields, or detect format-based ambiguities. It is the single skill whose absence degrades every other subtask output.

This is a synthesis task drawing entirely from this session's analysis. No search needed.

***

## Task 1.2 — Gap Classification: Skills by Subtask

**The question Task 1.2 answers:** *Which gaps in the brief inventory are blocking, and which can be carried as open questions?*

**Output:** `open-questions-register.yaml` — four subtasks, each populating the register from a different input array in `brief-inventory.yaml`

***

### Subtask 1 — Required Field Gap Classification

**Question:** For each required field with non-PRESENT coverage, would proceeding without it cause a downstream step to fail?

**Output:** Register entries for all required fields with classification BLOCKER | WARNING | INFO

#### Skills Required

- **Step 2 and Step 3 policy documents loaded before starting.** Gate 1 — *"would getting this wrong cause Step 2 or Step 3 to fail?"* — cannot be answered from Step 1's policy alone. The executor must know what each required field is consumed for downstream. `appetite` is not consumed by Step 2 or Step 3 directly, but it is required by the manifest schema — Gate 3 catches it. Without Step 2/3 policy knowledge, Gate 1 produces false negatives. 

- **Three-gate classification sequence, applied in order.** Gate 1: downstream failure test. Gate 2: output validity test (can the manifest DoD be met without this value?). Gate 3: required field format rule test (is the value present but in an invalid form?). An executor who applies only Gate 1 misses fields that fail Gate 3 only — like `appetite` with a valid duration statement that doesn't map to a valid enum. The sequence is non-negotiable: Gates 1 and 2 test for impact; Gate 3 tests for form. 

- **Format rule knowledge per required field.** Gate 3 is only executable if the executor knows each field's format rule. `techstack` must contain named technologies with versions. `appetite` must be `small | medium | large`. `approvedby` must match a `humanactors` entry. An executor running Gate 3 without format rule knowledge approves values that Task 1.4's self-check later rejects.

- **`gap_type` precision — four distinct values, each with a different consequence.** `ABSENT` → the brief contains no information for this field. `AMBIGUOUS-INCOMPLETE` → information exists but is insufficient to populate the field. `AMBIGUOUS-FORMAT` → information exists and is complete but not in the required format. `CONTRADICTION` → two statements provide conflicting values. Each `gap_type` determines the question type in Task 1.3. An executor who conflates AMBIGUOUS-INCOMPLETE with AMBIGUOUS-FORMAT formulates the wrong question: the first requires a value-retrieval question; the second requires a choice-based question presenting valid options. 

- **One-gap-one-entry discipline.** If `techstack` has three gaps (AstroJS version, Shadcn/ui version, React unconfirmed), three entries are created. Not one entry for `techstack`. Task 1.3 will produce one question per entry — a compound question for a compound entry violates FC-3. The downstream consequence is real: a single `techstack` entry with three gaps produces one question whose answer is a paragraph that cannot be cleanly parsed into three discrete `resolutionnote` values. 

- **BLOCKER downgrade constraint for `CONFIRMED-UNKNOWN`.** An entry becomes BLOCKER when classified. It can be downgraded to WARNING only if Alex confirms the information genuinely does not exist (`CONFIRMED-UNKNOWN`). It cannot be downgraded by the executor's judgment that *"we can probably proceed anyway."* This constraint must be a loaded rule, not a policy the executor follows when convenient.

#### Failure Modes

- **Step 2/3 policy not loaded.** `appetite` classified as INFO because no downstream step consumes it directly. Gate 3 not applied. Task 1.4 writes a non-enum value into the manifest. Self-check fails at item 6.

- **Three `techstack` gaps collapsed into one entry.** Task 1.3 formulates one question. Alex responds with a paragraph. Response classification (Subtask 3) is unclear. A follow-up is needed — which recreates the three-entry structure that should have been the starting point.

- **`AMBIGUOUS-FORMAT` classified as `AMBIGUOUS-INCOMPLETE`.** `appetite: "a few days of focused work"` becomes a value-retrieval question: *"What is your project appetite?"* Alex answers *"small — a few days."* But the question implied Alex hadn't answered at all — which isn't true. The correct question was a confirmation: *"Your timeline of a few days maps to 'small' — can you confirm?"* The wrong `gap_type` produced the wrong question.

***

### Subtask 2 — Optional Field Gap Classification

**Question:** For each optional field with non-PRESENT coverage, what is the downstream impact?

**Output:** Register entries for optional fields with classification WARNING | INFO (never BLOCKER by definition)

#### Skills Required

- **Explicit absence confirmation discipline.** Every optional field must be assessed — not just those that seem relevant. The Done condition requires confirming every optional field was visited, not just that entries were created for the ones that triggered classification. Silent skipping of an ABSENT optional field with "no downstream impact" produces a register that appears complete but is not. 

- **WARNING vs INFO threshold — impact-based, not intuition-based.** WARNING means a specific, named downstream step will produce a degraded output. INFO means the gap is noted for completeness with no identifiable downstream consequence. The threshold is not *"how important does this feel?"* — it is *"which downstream output degrades and by how much?"* An executor applying intuition rather than impact analysis produces inconsistent classifications across the register.

- **Conditional requirement recognition.** Some optional fields become effectively WARNING-level when other fields are populated in specific ways. `integrationrequirements` is optional by schema but becomes WARNING when `techstack` includes a form handler or when the brief mentions a contact form. This conditionality requires reading optional field classification against confirmed required field values — not in isolation. 

- **`schema_gap_flag` awareness for fields that don't exist.** Some brief content has clear downstream value but no manifest field to map to. Infrastructure readiness, maintainability requirements, design intent beyond reference examples — these are not ABSENT optional fields, they are ABSENT *from the schema itself*. The executor must distinguish between *"this optional field has no value"* and *"this information has no field"* — the second produces a register entry with `schema_gap_flag: true`. 

#### Failure Modes

- **Implicit conditional requirement missed.** `integrationrequirements` classified INFO because it is optional. A contact form is in the brief. The downstream consequence — Step 2's integration section cannot be drafted without a provider — is not assessed. OQ-1-08 is created with classification INFO rather than WARNING. Task 1.5 review presents it as an INFO item. Alex approves without understanding the Step 2 consequence.

- **Infrastructure readiness classified as ABSENT for `deploymenttarget`.** The statement *"I already have a Cloudflare account"* is not absence of deployment information — it is deployment-adjacent information with no manifest field. Classifying `deploymenttarget` as ABSENT misses this; classifying it correctly as AMBIGUOUS-INCOMPLETE doesn't capture the infrastructure readiness signal either. Only `schema_gap_flag: true` on a non-mappable-derived entry (OQ-1-11) preserves it. 

***

### Subtask 3 — Contradiction Classification and Linking

**Question:** Which contradictions require clarification before drafting, and how do they relate to other register entries?

**Output:** Register entries for contradictions; bidirectional `linked_questions` population for all related entries

#### Skills Required

- **Contradiction classification is always BLOCKER — no exceptions.** This is a loaded invariant, not a judgment call. A contradiction in the brief means the manifest cannot contain both values and cannot safely choose one without human confirmation. Downgrading a contradiction to WARNING requires the executor to be confident enough in the correct resolution to proceed without asking — which is a domain knowledge substitution for a human decision. Per L2, one-way decisions belong to humans. 

- **Linking pass as a distinct, named step.** After all register entries are created, a separate linking pass identifies all entry pairs that share an underlying cause. The linking is bidirectional: if OQ-1-05 is linked to OQ-1-10, OQ-1-10 must also be linked to OQ-1-05. This pass runs once, after Subtask 3 completes — not incrementally during subtask execution. Incremental linking produces orphaned linkages when earlier entries reference later entries that don't exist yet. 

- **Linked group identification — finding the underlying cause.** Two register entries are linked when resolving one resolution note contains information that resolves the other. The Workers/Pages contradiction (OQ-1-05) and the static/SSR ambiguity (OQ-1-10) are linked because confirming Cloudflare Pages resolves both. An executor who does not identify the underlying cause cannot identify the linked group. Domain knowledge is required here: understanding that Pages = static and Workers = server is the basis for the link.

- **Impact field specificity.** Each entry's `impact` field must name a specific downstream failure — not a general concern. *"Step 2 cannot be drafted"* is insufficient. *"Step 2 deployment section cannot specify the build output configuration without knowing whether Workers or Pages is the target"* is specific. The `impact` field is the primary signal Task 1.3 uses to formulate an impact statement in the clarification question. Vague impact → vague question → vague response.

#### Failure Modes

- **Contradiction downgraded to WARNING using domain knowledge.** The executor knows that AstroJS defaults to static output and that *"Cloudflare Workers"* was probably a naming mistake — Alex meant Pages. The contradiction is recorded as WARNING. Task 1.3 never asks about it. Task 1.4 writes `deploymenttarget: Cloudflare Pages` with `sourcetype: derivationrule` — but the derivation is a domain-knowledge substitution, not a documented rule. FC-1 fails. 

- **Linking pass skipped.** OQ-1-05 and OQ-1-10 are both created but `linked_questions: []` on both. Task 1.3 formulates two separate questions for the same underlying issue. Alex receives a question about the Cloudflare product and a separate question about the static constraint. One response resolves both; the executor only resolves OQ-1-05. OQ-1-10 remains OPEN. Task 1.4 begins with one OPEN BLOCKER — which the executor must either skip (invalid) or loop back through Task 1.3 to resolve.

***

### Subtask 4 — Non-Mappable Statement Classification

**Question:** Which non-mappable brief statements carry downstream consequences requiring a register entry?

**Output:** Register entries for consequential non-mappable statements (with `schema_gap_flag: true`); documented no-entry decisions for inconsequential ones

#### Skills Required

- **Downstream consequence assessment for non-schema content.** The executor must assess each `non_mappable[]` entry from `brief-inventory.yaml` against Steps 2–6 — not just Step 1. A statement that has no Step 1 consequence may have a Step 2 consequence. Infrastructure readiness affects Step 2's deployment section. Maintainability requirements may affect Step 3's roster. Design intent descriptors affect Step 4's pattern selection. The executor needs a working model of what each downstream step consumes.

- **Explicit no-entry documentation.** For every `non_mappable[]` entry that does not produce a register entry, the executor must record a no-entry decision. The Done condition for Subtask 4 requires explicit confirmation that every non-mappable entry was assessed — not just that entries were created for the ones that mattered. A register that appears complete may simply be one where non-consequential items were silently skipped. 

- **`schema_gap_flag` implications for framework feedback.** Entries with `schema_gap_flag: true` are not just register entries — they are signals to the framework that the manifest schema has a gap. An executor who understands this creates entries whose `candidate_field` suggestions are actionable: *"maintainability: string — records developer handoff requirement"* is more useful than *"some field for handoff requirements."* This skill is not required for Task 1.2 to complete correctly, but it determines whether the schema gap signal is usable by the framework.

#### Failure Modes

- **Subtask 4 skipped entirely.** The most common failure. The `non_mappable[]` array is processed in Task 1.1 with `downstream_note` values, but Task 1.2 treats it as already handled. OQ-1-11 (Cloudflare account readiness), OQ-1-12 (maintainability), and OQ-1-13 (design intent) are never created. All three appear in the session's Meridian register precisely because Subtask 4 ran. Their absence would produce a manifest whose `openquestions` section is missing three entries the human director should know about at Task 1.5 review. 

- **No-entry decisions not documented.** Three entries from `non_mappable[]` are inconsequential (vague expressions of enthusiasm, scheduling notes). The executor creates no register entries for them — correctly. But without documented no-entry decisions, a verifier cannot distinguish *"assessed and found inconsequential"* from *"never assessed."* The Done condition for Subtask 4 cannot be confirmed.

***

## Task 1.3 — Clarification Resolution: Skills by Subtask

**The question Task 1.3 answers:** *Can each blocking gap be resolved by asking Alex directly?*

**Output:** `CE-1-01.yaml` with all BLOCKER entries resolved, reclassified, or formally noted as `CONFIRMED-UNKNOWN` or `DECISION-REQUIRED`

***

### Subtask 1 — Question Formulation and Exchange Record Creation

**Question:** What is the precisely correct question to ask for each BLOCKER register entry?

**Output:** Exchange record shell created; one question per BLOCKER entry

#### Skills Required

- **`gap_type` → question type mapping, applied mechanically.** Each `gap_type` has a corresponding question structure that must be applied without deviation: 
  - `ABSENT` → value-retrieval question: *"What is X?"*
  - `AMBIGUOUS-INCOMPLETE` → value-retrieval question with context: *"You mentioned Y — what specifically is Z?"*
  - `AMBIGUOUS-FORMAT` → choice question presenting valid options: *"You mentioned [duration] — which of [small / medium / large] best fits?"*
  - `CONTRADICTION` → disambiguation question naming both interpretations: *"The brief mentions both A and B, which appear to conflict — which is correct?"*

  An executor applying judgment rather than this mapping produces questions that mix types — asking for a choice when a value is needed, or asking for disambiguation when a format mapping would close the gap.

- **FC-3 compound question prohibition — 25-word maximum, one gap per question.** The character limit is a proxy for the structural rule: one question resolves one gap. A question that requires two pieces of information to answer is a compound question by definition, regardless of word count. The executor must test every formulated question: *"Can this be fully answered by addressing one register entry?"* If no, it is compound. 

- **Parenthetical retrieval instructions — permitted, not compound.** *"Run `node --version` in your terminal and paste the result"* added to a question about Node.js version is a retrieval instruction, not a second question. It does not ask for two pieces of information — it helps Alex retrieve the one piece being asked for. The policy must permit these; an executor who strips them out produces questions that return `CONFIRMED-UNKNOWN` from a human who could have answered with a 10-second terminal check. 

- **Linked group detection — ask once, not twice.** Before formulating a question for any entry, the executor checks `linked_questions[]` for that entry. If two entries are linked, one question covers both — and the question is formulated against both entries' `gap` fields. An executor who formulates separate questions for linked entries violates the efficiency principle of FC-3 and confuses Alex with duplicate questions about the same underlying issue.

- **Impact statement precision.** Every question includes a one-sentence impact statement — not to explain to Alex why the executor is asking, but to help Alex understand the stakes so they provide a usable answer. *"This affects whether Step 2 can specify the deployment configuration"* is specific. *"This is needed to complete the project record"* is not. The impact statement is drawn from the register entry's `impact` field — not rewritten by the executor. 

- **Exchange record shell created before delivery, not after.** `initiatedat` is set at the moment of sending. The shell must exist before the questions are delivered. An executor who creates the record after Alex's response cannot set an accurate `initiatedat` — this is an audit integrity issue, not an administrative detail. 

#### Failure Modes

- **Compound question for linked entries.** OQ-1-05 and OQ-1-10 produce one question: *"The brief mentions both Cloudflare Workers and a fully static site — which is the correct deployment target, and does the static constraint still apply?"* This is compound: two questions, two answers required. Alex responds to the first. The executor records one `RESOLVED` and must create a follow-up for the second — which should have been the cascade update rule, not a second question.

- **`AMBIGUOUS-FORMAT` treated as `AMBIGUOUS-INCOMPLETE`.** OQ-1-07 (`appetite`) produces: *"What is the project appetite — small, medium, or large?"* — correct. If misclassified as AMBIGUOUS-INCOMPLETE: *"What is the project timeline?"* — Alex answers *"a couple of weeks"* and the executor is back where it started: AMBIGUOUS-FORMAT, requiring another exchange.

- **Exchange record created post-response.** The executor delivers questions to Alex, receives responses, then creates the exchange record with `initiatedat` estimated. In a synchronous session this is minutes off. In an asynchronous workflow it may be hours. The audit trail misrepresents when the questions were asked. 

***

### Subtask 2 — Batch Delivery and Blocking

**Question:** Has the complete batch been delivered to Alex as a single exchange, and is the process correctly blocked?

**Output:** `initiatedat` timestamp set; process suspended

#### Skills Required

- **Batch vs sequential discipline — all questions delivered once.** All BLOCKER questions are batched into a single exchange. One delivery, one block, one response. An executor who delivers questions sequentially — waiting for each response before formulating the next — multiplies the number of round trips unnecessarily and risks asking questions that later questions make irrelevant. If Q1 is *"Which Cloudflare product?"* and Q2 is *"Does the static constraint apply?"* — receiving Q1's answer before asking Q2 means the executor might be able to derive Q2's answer from Q1's response. The batch approach handles this through cascade updates in Subtask 3. 

- **Hard blocking — no optimistic pre-loading.** Once the exchange is delivered and `initiatedat` is set, the process blocks completely. The executor must not begin drafting the manifest, pre-populate fields where the answer seems obvious, or pre-load correction workflows. Any work done during the block that consumes unconfirmed values will need to be undone if Alex's responses differ from expectation. The block is genuine suspension, not an opportunity for parallel work. 

- **Clarity of the question package as presented to Alex.** Each question must be self-contained — Alex should not need to refer to other questions to answer any one question. If two questions are linked, the linking is noted in the presentation (*"Your answer to Q1 may also address Q2"*) but each question still stands independently. An executor who presents questions assuming Alex will read all of them before answering any of them has no guarantee that is how Alex will read them.

#### Failure Modes

- **Sequential delivery.** The executor asks Q1, receives an answer, formulates Q2, delivers Q2. Three questions become three exchange cycles. The Meridian brief has 7 BLOCKER entries. Sequential delivery means seven round trips before Task 1.4 can begin — avoidable entirely with a single batch.

- **Partial batch.** The executor batches questions for the four tech stack entries but delivers the `appetite` and `deploymenttarget` questions separately because they feel different in character. Two exchange records are created for a single Task 1.3 run. The exchange record series is CE-1-01 and CE-1-02. The register entries for the second batch show a different `resolvedatexchange` reference than the first. FC-8 carry-forward must now reconcile two exchange references for a single step's resolution work. Unnecessary complexity with no benefit. 

***

### Subtask 3 — Response Classification and Register Update

**Question:** Does each response constitute a resolution, and what does the register entry become?

**Output:** All BLOCKER entries reclassified; `resolutionnote` populated; `derivation_flag` set where applicable; cascade updates applied

#### Skills Required

- **Classification-before-action as a hard sequence rule.** The response is classified before any register entry is updated. The four classifications — `RESOLVED`, `CONFIRMED-UNKNOWN`, `DECISION-REQUIRED`, `UNCLEAR` — are mutually exclusive. An executor who begins updating the register mid-classification produces partial updates if the classification changes upon reading the full response. The most dangerous version: a response that starts with *"Yes, go with X"* and ends with *"but actually I'm not sure about Y"* — classifying on the first sentence produces `RESOLVED`; reading the full response produces `UNCLEAR`. 

- **`derivation_flag` identification — acceptance of a rule, not a value.** When Alex says *"latest stable is fine"*, this is not a `RESOLVED` response with value *"latest stable."* It is an acceptance of a derivation rule: the executor is authorised to resolve *"latest stable"* to a specific version via lookup at the time of drafting. The `derivation_flag: true` in the exchange record is the machine-queryable signal that Task 1.4's pre-drafting step will query. An executor who records this as `RESOLVED` with `resolutionnote: "latest stable"` produces a manifest entry that violates the `techstack` format rule. 

- **Linked cascade execution — a named step, not an implied side effect.** After each `RESOLVED` classification, the executor queries the register for all entries with `linked_questions` referencing the just-resolved entry's `questionid`. For each linked entry, the same resolution is applied, citing the same exchange reference. This is not optional — an unresolved linked entry after its parent entry is resolved is an inconsistent register. OQ-1-10 must be cascade-updated when OQ-1-05 is resolved; the manifest cannot have `deploymenttarget: Cloudflare Pages` and `constraints: fullyStatic` without both underlying entries being RESOLVED. 

- **`UNCLEAR` handling — single follow-up, not re-presenting the full batch.** When a response is `UNCLEAR`, the executor identifies the single follow-up question that resolves the ambiguity — not the original question rephrased. *"You mentioned a timeframe — which of small, medium, or large best describes your appetite?"* is the follow-up for an UNCLEAR appetite response. The `initiatedat` timestamp of the original exchange is unchanged. A `followuprequestedat` timestamp is added. 

- **`DECISION-REQUIRED` routing to FC-9.** When Alex's response indicates the information does not exist because a decision is unmade, the executor does not attempt further clarification. FC-3's scope ends here. FC-9 is invoked: a Decision Request record is created, the register entry is updated to `resolutionstatus: AWAITING-DECISION`, and the step enters a decision-specific block state. This routing is a loaded rule — an executor who attempts to resolve `DECISION-REQUIRED` through further clarification questions is working outside FC-3's scope. 

- **Verbatim recording in `resolutionnote`.** Alex's response text is recorded verbatim — not summarised, not normalised. The traceability chain from field value back to human response depends on this verbatim record. A paraphrased `resolutionnote` cannot independently verify that the manifest value matches what Alex actually said.

#### Failure Modes

- **"Latest stable" recorded as a final value.** OQ-1-01 gets `resolutionnote: "AstroJS latest stable"`, `resolutionstatus: RESOLVED`, `derivation_flag: false`. Task 1.4's pre-drafting step has no `derivation_flag: true` entries to query. The manifest field is written as `AstroJS (latest stable)` — a format rule violation. 

- **Cascade update missed.** OQ-1-05 resolved, OQ-1-10 not cascade-updated. Task 1.4 begins with OQ-1-10 still OPEN. The executor discovers this during required field population — the `constraints` field has an OPEN BLOCKER reference. Task 1.4 cannot proceed without re-engaging Task 1.3. The cascade update that should have happened in Subtask 3 becomes a Task 1.4 blocker.

- **`UNCLEAR` response upgraded to `RESOLVED`.** Alex says *"I think React is probably needed."* The executor records `RESOLVED: React confirmed.` The word *"probably"* signals uncertainty — this is UNCLEAR, requiring a follow-up. *"React 19.x"* in the manifest traces to an uncertain confirmation. A Step 2 executor who pulls React from the manifest has an unclear basis for it. 

***

## Task 1.4 — Manifest Drafting: Skills by Subtask

**The question Task 1.4 answers:** *Can all confirmed values be structured into a valid, traceable manifest?*

**Output:** `project-manifest.yaml` in DRAFT status; `project-manifest.traceability.yaml` covering every non-empty field

***

### Subtask 1 — Pre-Drafting Derivation Resolution

**Question:** For every `derivation_flag: true` entry in the exchange record, what is the specific resolved value?

**Output:** Derivation entries in the traceability record; new register entries for any gaps discovered

#### Skills Required

- **Exchange record query as the first act of Task 1.4 — before field one.** The executor queries `CE-1-01.yaml` for all responses with `derivation_flag: true`. This is not optional and not a preliminary check — it is the first action of the task. An executor who begins populating fields before querying derivation flags will encounter the gap mid-population and must either retroactively update already-written entries or proceed with invalid placeholder values. 

- **Version lookup capability or defined fallback.** Resolving *"latest stable"* to `AstroJS 5.3.0` requires external access to a package registry or release page. The executor must either perform the lookup or apply the defined fallback: `CONFIRMED-UNKNOWN`, register entry updated, field left empty. Guessing a version number is not a fallback — it produces an invented value with no source reference, which fails FC-1. 

- **Implicit dependency detection during pre-drafting.** While resolving explicit derivations, the executor checks whether any resolved tech stack entry implies an unlisted dependency. React confirmed → `@astrojs/react` implied. This requires domain knowledge of the declared stack. The implication must produce a new register entry (OQ-1-14) before the value is written — the register entry is the evidence that the derivation was authorised, not invented. 

- **Traceability entry format for derivation-resolved values.** Derivation-sourced values use `sourcetype: derivationrule` with a `sourcereference` that names the rule (`latestStableVersion`), the lookup date, the lookup source, and the authorising exchange reference. This is a more complex traceability entry than a `brief` or `clarificationanswer` type — the executor must know the format before writing it.

#### Failure Modes

- **Pre-drafting step skipped.** The executor begins populating `techstack` from the register's `resolutionnote` values. OQ-1-01 has `resolutionnote: "latest stable is fine"` and `derivation_flag: true`. The executor writes `techstack[0]: AstroJS (latest stable)`. Format rule violation. `@astrojs/react` is never detected. The manifest's `techstack` is incomplete at DRAFT time.

- **Version guessed without lookup.** The executor cannot access npm. Rather than recording `CONFIRMED-UNKNOWN`, writes `AstroJS 5.x`. The traceability entry says `sourcetype: derivationrule` — but there is no lookup date, no lookup source, and no specific version. A verifier cannot confirm where `5.x` came from. FC-1 fails. 

***

### Subtask 2 — Required Field Population

**Question:** Can each required field be populated with a specific, traced, format-conformant value?

**Output:** All required fields populated in `project-manifest.yaml`; corresponding traceability entries in companion record

#### Skills Required

- **Traceability-alongside-field as one operation, two writes.** Field value written → traceability entry written immediately — before moving to the next field. Not after all fields are written. Not in a separate pass. The two writes are simultaneous because the source reference is unambiguous at the moment of writing; reconstructing it later introduces risk of misattribution. An executor who writes the full manifest and then produces the traceability record is reconstructing provenance rather than recording it. 

- **Description assembly rule — brief language without editorial voice.** The `description` field is assembled from multiple brief statements. Every sentence must trace to a named statement ID. No sentence from the executor's own voice may appear. The assembly rule: include project type, primary purpose, and key deliverable; exclude constraints, deployment details, and named actors — those have dedicated fields.  An executor who adds a sentence not sourced to the brief has introduced an invented value into a required field. 

- **`techstack` format rule enforcement during population.** Entries must be named technologies with versions. An entry that passes the pre-drafting step (derivation resolved) but is written without a version number (e.g. `pnpm` version not confirmed during Task 1.3) must be caught here. The correct action: create a new register entry, resolve via derivation, then write. The pre-drafting step catches planned derivations; this subtask catches unplanned ones discovered during population.

- **`humanactors` entry structure.** The field requires at least one entry with `role: humandirector`, with `name` matching exactly the name that will be used in `approvedby` at Task 1.5. An executor who writes `name: Alex` rather than `name: Alex Chen` creates a mismatch that Task 1.5 Subtask 5's `approvedby` validation will reject.

- **`appetite` enum mapping from resolution note.** The `resolutionnote` for OQ-1-07 contains Alex's verbatim words (*"small — a few days of focused work"*). The manifest field value is the enum: `small`. The traceability entry cites the `resolutionnote`. An executor who writes `appetite: "small — a few days"` fails the format rule. The enum value and the verbatim quote are different things serving different purposes.

#### Failure Modes

- **Traceability written after all fields.** The executor writes all required fields, then produces the traceability record from memory of what was used for each field. `description` sources are reconstructed as S-01 only — the executor no longer recalls which other statements contributed. The FC-1 verifier checks `description` against S-01 and finds the sections and visual style content not present in S-01. FC-1 fails. 

- **`pnpm` in `techstack` without version.** The executor writes `pnpm` — confirmed via CE-1-01 Q-CE-1-01-04, but no version was asked or answered. The format rule requires a version. The field is written without one because pre-drafting only caught the flagged derivations. No new register entry is created. Task 1.4 self-check item 3 (no placeholders in `techstack`) is later supposed to catch this — but `pnpm` without a version is not a placeholder in the traditional sense; it may pass a naive self-check.

***

### Subtask 3 — Optional Field Population

**Question:** For each optional field, should it be populated, left empty, or recorded as tentative with an open question reference?

**Output:** All optional fields either populated with traced values, explicitly empty, or recorded with register cross-references

#### Skills Required

- **Restraint on empty fields — empty is a valid, complete state.** An optional field absent from the brief is left empty (`[]` or `null` depending on type) with a traceability entry of `sourcetype: notpresentininput`. The executor must not populate it with a reasonable default. `existingassets: []` with `sourcetype: notpresentininput` is a complete, correct entry. `existingassets: ["none stated"]` is an invented value. 

- **Tentative value handling for AMBIGUOUS optional fields.** A field with an ambiguous optional value — like `integrationrequirements` where Formspree was mentioned tentatively — must not be recorded as confirmed. The correct approach: record what was said, note it is tentative, reference the open question ID. `provider: Formspree (tentative — see OQ-1-08)` with `sourcetype: clarificationanswer, sourcereference: "CE-1-01 Q-CE-1-01-08: tentative mention only"` is a complete entry. A confirmed-sounding entry without the tentative notation will mislead Step 2. 

- **`constraints` and `outofscope` format rule — stated, not inferred.** These fields have explicit prohibitions against inference. The executor must source every entry to a brief statement or clarification answer. An entry with no source reference is an invented constraint. Domain-knowledge-inferred constraints (*"AstroJS implies no SSR"*) are not valid entries — unless Alex explicitly stated the constraint in a form the executor can cite. 

- **`referenceexamples` verbatim extraction.** If Alex named specific design references, they enter this field verbatim. The executor must not normalise (*"minimalist SaaS landing pages"* in place of *"Linear.app, Stripe marketing pages"*) or editorially describe. The reference names are the values.

#### Failure Modes

- **`integrationrequirements.provider` written as `Formspree` without tentative notation.** Step 2's integration section is drafted around Formspree. Alex later selects a different provider. Step 2 must be partially redrafted because a tentative brief mention was treated as a confirmed value.

- **`constraints` populated with inferred AstroJS static output constraint.** No brief statement says *"fully static."* The AstroJS default behaviour implies it. The executor writes `constraints: [fullyStatic: true, noServerRendering: true]`. FC-1 fails — no brief statement or clarification answer supports these entries. 

***

### Subtask 4 — Open Questions Field Population

**Question:** Which register entries belong in the manifest's `openquestions` field?

**Output:** `openquestions[]` populated with all WARNING and INFO entries

#### Skills Required

- **Completeness test — all non-RESOLVED register entries must appear.** Every register entry with `resolutionstatus: OPEN` and classification `WARNING` or `INFO` must appear in `openquestions`. The executor cannot filter by *"likely to matter to Alex."* The manifest's `openquestions` field is the human-readable presentation of the register's non-blocking content. If it is incomplete, Task 1.5 presents an incomplete picture — Alex approves without knowing about gaps the process knows about.

- **`openquestions` entry format — field, gap, impact, classification.** Each entry maps to its register source: `field` is the register entry's `field` value, `gap` is the register entry's `gap` (verbatim — not paraphrased), `impact` is the register entry's `impact`, `classification` is WARNING or INFO. The executor must not rewrite these fields — they come from the register. Rewriting loses the traceability link between the manifest entry and its register source. 

- **`CONFIRMED-UNKNOWN` entries included as WARNING.** Entries reclassified from BLOCKER to WARNING via `CONFIRMED-UNKNOWN` carry into `openquestions` with their current classification. They are not omitted because they were once BLOCKER — they are included because they remain unresolved and carry downstream impact. An executor who omits them because *"the BLOCKER was resolved"* misunderstands the distinction between *"the blocking condition is resolved"* and *"the gap is filled."*

#### Failure Modes

- **OQ-1-11 (schema_gap_flag) omitted.** The executor only includes entries with a named manifest `field`. OQ-1-11 has `field: null` (no manifest field exists). It is omitted. Alex reviews the manifest and approves without knowing that Cloudflare account readiness was noted but has no place in the manifest. Step 2's deployment section will either assume Alex needs to procure a Cloudflare account, or will ask again — re-raising a gap that Step 1 already knew about.

- **`openquestions` entries rewritten editorially.** OQ-1-08's `gap` field reads: *"Form handler provider not confirmed — Formspree mentioned tentatively."* The executor rewrites: *"The contact form configuration is still to be determined."* The rewrite loses the Formspree mention, loses the tentative qualifier, and loses the specificity. Task 1.5's review package presents the rewritten version to Alex. Alex approves without knowing Formspree was the tentative option.

***

### Subtask 5 — Self-Check

**Question:** Does the DRAFT manifest satisfy all correctness conditions before Task 1.5 review?

**Output:** 15-item self-check passed; `status: DRAFT` set only after all items pass

#### Skills Required

- **Self-check before `status: DRAFT` — not after.** `DRAFT` signals readiness for human review. Setting it before the self-check means a manifest with known defects reaches Alex. The self-check is the executor's quality gate — the reviewer in Task 1.5 is the human's quality gate. Both must exist; neither substitutes for the other. 

- **Placeholder detection for `techstack` entries.** Self-check item 3 tests that no `techstack` entry contains a placeholder value (`latest stable`, `TBD`, `x.x`, or any non-specific version indicator). This requires the executor to know what a placeholder looks like. `AstroJS 5.3.0` is not a placeholder. `AstroJS 5.x` is. `AstroJS (latest)` is. An executor who cannot distinguish specific versions from version patterns will pass a manifest with invalid `techstack` entries.

- **FC-1 cross-reference test — every field has a traceability entry.** Self-check item 13 (or equivalent) requires the executor to confirm that the traceability companion record has an entry for every non-empty manifest field. This is not a count check — it is a field-by-field correspondence check. A companion record with 12 entries for a manifest with 14 non-empty fields passes a count check of *"entries exist"* but fails a field-by-field check. 

- **`humanactors` structural check — at least one `humandirector` entry.** The executor confirms that `humanactors` contains at least one entry with `role: humandirector` and a `name` value that will match `approvedby` at Task 1.5. This cross-checks two fields against each other — not just each field in isolation.

- **`approvedat` and `approvedby` absence check.** These fields must not be present at DRAFT time — their presence would indicate they were set by the executor, not by Alex's action. An executor who pre-populates these fields in anticipation of Alex's approval has violated FC-4 Tier 1's requirement that approval is set by a human action. 

#### Failure Modes

- **Self-check run after `status: DRAFT` is set.** The executor sets `DRAFT` to signal completion, then runs the self-check. A failure at self-check means the manifest has been presented to the system as ready when it is not. Depending on workflow design, Alex may receive the unverified manifest before the self-check failure is caught.

- **FC-1 check done by count rather than by field.** The traceability record has 11 entries. The manifest has 11 non-empty fields. Count matches — self-check passes. But `openquestions` has no traceability entry (it was populated from the register, not from the brief or clarification). The count coincidence masks the missing entry. A verifier later finds `openquestions` has no source reference. FC-1 fails post-approval. 

***

## Task 1.5 — Human Review: Skills by Subtask

**The question Task 1.5 answers:** *Does Alex confirm that the manifest accurately represents their intent?*

**Output:** `project-manifest.yaml` in APPROVED status; FC-4 audit log entry; `RR-1-01.yaml`

***

### Subtask 1 — Presentation Preparation

**Question:** What exactly is Alex being asked to confirm, and is the review package accurate?

**Output:** Review package with Part 1 (field values) and Part 2 (open questions); `summaryvalidated: true` confirmed before delivery

#### Skills Required

- **Two-part structure distinction — field values and open questions are separate asks.** Alex is being asked to confirm two distinct things: (1) that field values accurately represent their intent, and (2) that they are aware of the unresolved gaps before approving. Conflating these into a single presentation produces responses that mix confirmation of values with reactions to gaps — which are harder to classify. A response to a mixed presentation may say *"yes but about that Formspree thing..."* — which is partly approval and partly a gap reaction. The two-part structure separates these. 

- **Summary fidelity validation — every summary value checked against the manifest before delivery.** The review package summary is generated from the manifest — not from memory, not from the traceability record. Before delivery, every summary value is checked against its source manifest field. A rendering error in the summary means Alex approves a description of the manifest that doesn't match the canonical document. The executor cannot assume the summary is correct — it must be verified. 

- **All open questions presented — no filtering by "likely relevance."** Part 2 must include all five OPEN register entries, classified by severity (WARNING before INFO). The executor must not filter by *"this one probably won't matter to Alex"* — that judgment is Alex's to make, not the executor's. 

- **Approval instruction precision.** The instruction to Alex must name exactly what constitutes an approval and what constitutes a returned correction. *"Confirm the field values above accurately represent your intent, and that you have noted the open questions"* is specific. *"Does this look right?"* is not — it invites reflexive affirmation rather than deliberate review.

#### Failure Modes

- **Part 2 omitted.** Alex sees only field values. Approves. OQ-1-08 (Formspree unconfirmed, WARNING) was never presented. The approval is not informed consent. Task 1.5 is technically completed but the approval does not satisfy FC-4's requirement for an informed approval. 

- **Summary not validated before delivery.** The `description` summary reads *"A single-page marketing website for Meridian Consulting with CMS support"* — a rendering error included a phrase from a prior draft. Alex reads the summary and approves. The canonical manifest contains no CMS reference. The approval is for a summary that does not match the document it purports to summarise.

***

### Subtask 2 — Presentation and Blocking

**Question:** Has the review package been delivered with an accurate timestamp and is the process genuinely blocked?

**Output:** `presentedat` set at moment of delivery; process suspended; `RR-1-01.yaml` filed

#### Skills Required

- **Record-before-deliver discipline — `presentedat` set at the moment of delivery.** Not when the executor decides to send. Not when Alex responds. At the moment the package reaches Alex. In a synchronous session these may be simultaneous. In any asynchronous workflow they are distinct events. The record must be created and `presentedat` set before delivery completes — otherwise the timestamp is a reconstruction. 

- **Hard blocking without exception.** No further Task 1 work proceeds until Alex responds. No partial pre-loading of correction workflows. No drafting of anticipated correction outcomes. The block is genuine process suspension. An executor who performs preparatory work during the block has introduced assumptions about Alex's response that may not hold — and those assumptions may persist if the executor does not carefully undo them when the actual response arrives.

- **Review record as an FC-4 artefact — distinct from CE records.** `RR-1-01.yaml` is filed in `.framework/reviews/`, not in `.framework/clarifications/`. The distinction is not administrative — CE records document FC-3 clarification exchanges; RR records document FC-4 approval events. Conflating them loses the framework's ability to independently query approval events versus clarification events. 

#### Failure Modes

- **`presentedat` set at response receipt time.** In an asynchronous workflow, Alex reviews the manifest two hours after delivery and responds. The executor creates the record when the response arrives and sets `presentedat` to the current time. The record shows Alex approved a manifest two hours before they received it. Audit trail integrity fails. 

***

### Subtask 3 — Response Classification

**Question:** Is Alex's response an approval, a correction, or something that requires follow-up?

**Output:** `responseclassification: APPROVED | RETURNED | UNCLEAR`; appropriate path initiated

#### Skills Required

- **Read the full response before classifying.** The response is classified as a whole, not sentence by sentence. A response that begins *"Approved"* and ends with *"but appetite should be medium"* is `RETURNED`. Reading to the end before classifying is the single most important skill in this subtask — the most consequential misclassification (embedded correction treated as clean approval) results from classifying on the opening word. 

- **Minimum explicit approval threshold — loaded definition, not judgment.** The threshold is: the response names the document (or is unambiguously in the context of the review) and contains a deliberate affirmation. Valid: *"approved"*, *"confirmed"*, *"yes, that's correct."* Invalid: *"fine"*, *"sure"*, *"looks good"*, *"ok."* This is a policy definition. The executor applies it mechanically — it is not a case where *"looks good sounds like an approval to me"* is a valid substitution. 

- **Scope change detection for `RETURNED` responses.** When a correction modifies a field whose value was used to resolve a prior BLOCKER register entry, the executor must check whether the correction invalidates that resolution before applying it. Removing the `fullyStatic` constraint is not a simple field edit — it reopens OQ-1-10 (Workers/static contradiction). The executor must know which register entries were used to resolve which fields. This requires having the register open during classification. 

- **`UNCLEAR` follow-up precision — one question, resolving one ambiguity.** When the response is `UNCLEAR`, the executor identifies the single follow-up question that resolves the ambiguity. Not the original question rephrased. Not a request to re-read the manifest. One question targeted at the specific ambiguity in the response.

#### Failure Modes

- **"Looks good to me" classified as `APPROVED`.** The audit log records this as the approval statement. A verifier reading the record cannot confirm a deliberate decision was made — *"looks good"* is not an explicit affirmation. FC-4 Tier 1 requires an explicit, deliberate approval statement. The approval is not FC-4 compliant. 

- **Embedded correction ignored.** Response: *"Approved — but appetite should probably be medium since I said 1–2 weeks."* Classified as `APPROVED`. `status: APPROVED` set. Manifest contains `appetite: small` in an APPROVED document, directly contradicting Alex's last statement. The word "approved" led the executor to classify on the opening word, never reaching the correction at the end. 

***

### Subtask 4 — Correction Application *(conditional)*

**Question:** Has the correction been applied correctly, and does the result need re-review?

**Output:** Corrected field value; new traceability entry with `sourcetype: correction`; old traceability entry retained with `supersedes` reference; `CR-1-xx.yaml`; change summary for re-presentation

#### Skills Required

- **Correction scope containment — only the corrected field changes.** The correction names a field and a value. Only that field is updated. Adjacent fields that the executor might judge should also change — because the correction implies something about them — are not touched unless explicitly corrected. If Alex corrects `appetite` to `medium`, `description` is not touched. Scope containment is not a courtesy — it is a discipline that prevents the executor from making scope decisions that belong to Alex. 

- **Traceability chain integrity — retain old entry, add new entry with `supersedes`.** The correction produces a new traceability entry. The old entry is retained. Two entries for one field is correct — it is the audit trail of the field's history. An executor who replaces the old entry loses the record that the value changed. A verifier reading the manifest cannot confirm the correction occurred — the field looks as though `medium` was always the value. 

- **Value correction vs scope addition classification.** A correction that changes an existing field's value is applied directly. A correction that introduces new content (a new `techstack` entry, a new constraint) is a scope addition — it requires a lightweight Task 1.1–1.3 mini-cycle before entering the manifest. The executor must classify the correction before applying it. Applying a scope addition as a value correction produces an untraced field value with `sourcetype: correction` but no underlying brief statement or clarification answer supporting the added content. 

- **Change summary for re-presentation.** Every re-presentation after a correction includes a change summary naming the field, the previous value, and the corrected value. Alex is asked to confirm the correction was applied correctly, not to re-read the full manifest. An executor who re-presents the full manifest without a change summary forces Alex to find the changed field — which they may or may not succeed at.

- **`UNSTABLE-FIELD` flag — triggered on second correction to the same field.** If the same field is returned for correction a second time, the executor flags it as `UNSTABLE-FIELD` and requests a definitive statement from Alex before re-presenting. This prevents the correction loop from cycling indefinitely on a field the human cannot seem to settle. 

#### Failure Modes

- **Old traceability entry deleted.** `appetite` traceability record is updated in-place from `small` (CE-1-01 source) to `medium` (CR-1-01 source). The record now shows one entry with `sourcetype: correction`. A verifier reading this entry sees *"the appetite was corrected to medium"* but has no record of what it was corrected from. The correction event loses its evidential value — it looks like a field whose value was medium from the start, not one that changed. 

- **Scope addition treated as value correction.** Alex says *"add Tailwind to the stack."* The executor adds `Tailwind CSS 3.x` to `techstack` with `sourcetype: correction, sourcereference: CR-1-01`. Tailwind was not in the brief, not in any register entry, not in any clarification exchange. Its addition implies new build tooling, new config entries, and potentially conflicts with Shadcn/ui's styling approach. None of these consequences are assessed. The manifest is re-presented with Tailwind in the tech stack as if it were a simple value change. 

***

### Subtask 5 — Approval Recording

**Question:** Has the approval been recorded in a form that satisfies FC-4 Tier 1 with full attribution and accurate timestamps?

**Output:** `status: APPROVED`; `approvedat`; `approvedby`; FC-4 Tier 1 audit log entry; `RR-1-01.yaml` completed

#### Skills Required

- **`approvedby` exact-match validation against `humanactors`.** Before setting `status: APPROVED`, the executor confirms that the name in Alex's response — which may be *"Alex"*, *"Alex C"*, or *"Alex Chen"* — maps to exactly the `name` value in the `humanactors` entry. The manifest `approvedby` field must contain the exact value from `humanactors`. *"Alex"* as `approvedby` when `humanactors` contains *"Alex Chen"* is a mismatch that FC-4 rejects. The resolution: use the `humanactors` entry's `name` value, not the name as signed in the response, provided the identity is unambiguous. 

- **`approvedat` as human action timestamp — not executor processing timestamp.** `approvedat` records when Alex approved — the datetime of Alex's response, not when the executor processed it. In synchronous sessions the gap is seconds. In asynchronous workflows it may be hours. The policy is explicit: record when the human acted. An executor who sets `approvedat` to the current datetime at the time of processing has misrepresented the approval timeline. 

- **`approvalstatement` — verbatim, minimum 5 words, required.** The FC-4 audit log entry's `approvalstatement` field contains Alex's actual words. Not a paraphrase. Not a template statement (*"humandirector approved the manifest."*). Alex's verbatim words are the evidence of deliberate decision-making. A template statement is a status record — which already exists in the `status` field. The audit log entry is evidence, not a status mirror. 

- **Post-approval immutability — no writes after `status: APPROVED`.** Once `status: APPROVED` is set, neither the manifest nor the companion traceability record may be modified. Any post-approval correction — however minor — requires returning the manifest to DRAFT and re-running Task 1.5 from Subtask 1. An executor who notices a traceability entry is incomplete after APPROVED is set must create a correction record rather than editing the companion file. 

- **Audit log entry as independent evidence.** The audit log entry exists independently of the manifest field. The `status: APPROVED` field is a state indicator. The audit log entry is proof. Both must exist. An executor who considers the `status` field sufficient has not satisfied FC-4 Tier 1's requirement for an independent approval record. 

#### Failure Modes

- **`approvedat` set to executor processing time in an asynchronous workflow.** Alex emailed approval at 11:00. The executor processes the email at 14:00. `approvedat: 14:00`. The audit trail shows the manifest was approved three hours after Alex actually acted. For a delivery with a strict timeline, this misrepresents the project history. 

- **`approvedby: "humandirector"` — role title instead of name.** FC-4 requires attribution to a named human. A role title is not independently verifiable — it does not survive personnel changes, and it cannot be confirmed against the `humanactors` entry because `humanactors` contains names, not role identifiers as primary keys. 

- **Traceability companion record updated post-approval.** The executor notices OQ-1-09's traceability entry is missing a `sourcereference`. Updates `project-manifest.traceability.yaml`. The manifest itself is unchanged — but the companion record, which together with the manifest constitutes the verified output set, has been modified after the seal was set. The APPROVED state is no longer fully intact. Any verifier whose check includes *"has the traceability record been modified post-approval?"* will produce a finding. 

***

## Summary — Skills Compendium, Tasks 1.2–1.5

| Task | Subtask | Critical skill | Most consequential failure |
|---|---|---|---|
| 1.2 | ST1 Required fields | Three-gate sequence with Step 2/3 policy loaded; gap_type precision | Gate 3 not applied; format-invalid value passes as PRESENT |
| 1.2 | ST2 Optional fields | Conditional requirement recognition; `schema_gap_flag` awareness | Conditional WARNING misclassified as INFO |
| 1.2 | ST3 Contradictions | Contradiction always BLOCKER; linked pass as named step | Contradiction downgraded via domain knowledge; linking skipped |
| 1.2 | ST4 Non-mappable | Schema exhaustion check; no-entry documentation | Subtask skipped entirely; OQ-1-11/12/13 never created |
| 1.3 | ST1