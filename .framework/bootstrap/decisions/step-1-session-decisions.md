Good notes. Addressing each before stating whether decisions are needed.

***

## Note Responses

**On brief form:** Agreed — Step 0 is out of scope. This simplifies Subtask A. The policy should not prescribe how a brief arrives. Step 1 receives it in whatever form and proceeds. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

**On decomposing prose into declarative statements:** This is a strong idea and warrants a decision (see below). The short answer is it should be a distinct, new subtask — not folded into Subtask A. Subtask A is orientation (read, form a whole-picture impression before acting). The decomposition is an active transformation with a structured output. Collapsing them conflates reading with processing. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

**On terminology:** Agreed — the policy should use widely accepted vocabulary. The concepts in FC-2 are settled (three tiers, two terminal states) but the labels should be reviewed before they propagate into every subsequent task, step policy, and skill file. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

**On whether decisions are needed before Task 1.2:** Yes — two decisions. Task 1.2 is entirely about gap classification. If the vocabulary isn't settled and the Task 1.1 output structure isn't confirmed, Task 1.2 cannot be precisely defined. Both decisions are low-effort but high-leverage.

***

## Decision 1 — Subtask Structure for Task 1.1

**The question:** Where does the declarative statement decomposition sit?

The proposed insertion is a new subtask between the current Subtask A (Read in full) and Subtask B (Field-by-field classification). Under this structure, all subsequent subtasks operate on a pre-processed statement list rather than raw prose — making them faster, more reliable, and easier to test.

**Proposed revised Task 1.1 subtask sequence:**

| # | Subtask | Input | Output |
|---|---|---|---|
| A | **Brief Orientation** — read in full; form a holistic impression before classifying anything | Raw brief | Mental/noted whole-picture impression; no output document |
| **B (new)** | **Statement Decomposition** — parse the brief into discrete, atomic declarative statements; tag each with candidate field(s); score each for clarity vs. ambiguity; link apparent contradictions | Raw brief + schema | Structured statement list: `[statement_text, candidate_fields[], clarity_score, linked_statements[]]` |
| C | **Required Field Mapping** — for each required field, identify supporting statements; classify as PRESENT / ABSENT / AMBIGUOUS | Statement list | Required field inventory |
| D | **Optional Field Mapping** — same for optional fields | Statement list | Optional field inventory |
| E | **Non-Mappable Statements** — identify statements with no field match | Statement list | Non-mappable list |
| F | **Contradiction Review** — review pre-linked statement pairs; confirm or dismiss each as a contradiction | Linked statements from B | Contradiction list |

**Options:**

- **Option A** — Add the decomposition as a new distinct Subtask B, shifting existing subtasks to C–F. *(Recommended)*
- **Option B** — Fold the decomposition into Subtask A, making A a combined "read + decompose" step. Simpler on paper, but the skills and outputs of reading and decomposing are different. Orientation is passive; decomposition is structured production — merging them obscures both.
- **Option C** — Keep the current subtask sequence unchanged; treat decomposition as an optional technique the agent may use internally rather than a formal step. This sacrifices the traceability and testability benefits the idea offers.

**Recommendation:** Option A. The decomposition's output (the statement list) is itself a reviewable, testable intermediate artefact. It forms the input to four subsequent subtasks, making it load-bearing — not just a technique. Making it explicit protects against incomplete or inconsistent classification by ensuring every part of the brief is processed before any field is mapped.

***

## Decision 2 — Gap Classification Vocabulary

**The question:** What labels should the three-tier FC-2 taxonomy use? [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

The three concepts and their decision rules are settled. Only the labels need confirming. The current labels are `BLOCKING / WARNING / LOWRISK`.

**Options:**

| Option | Tier 1 (stops work) | Tier 2 (quality impact) | Tier 3 (noted only) | Notes |
|---|---|---|---|---|
| **A** — Current labels | `BLOCKING` | `WARNING` | `LOWRISK` | Internally consistent; `LOWRISK` is less standard than the others |
| **B** — Jira/GitHub standard | `BLOCKER` | `WARNING` | `INFO` | `BLOCKER` and `WARNING` are universally understood in software tooling; `INFO` is standard in log-level vocabulary |
| **C** — Risk management | `CRITICAL` | `HIGH` | `LOW` | Familiar in risk/QA contexts; `CRITICAL` and `BLOCKER` have different connotations — critical implies severity, blocker implies progress impact |
| **D** — RFC 2119 inspired | `MUST` | `SHOULD` | `MAY` | Precise; widely used in technical specifications; but these read as requirement strength, not gap severity — they fit what the brief *must contain*, less well as gap labels |

**Terminal states** (currently `BLOCKING-RESOLVED` and `BLOCKING-CONFIRMED-UNKNOWN`) become under each option:

- **Option A:** `BLOCKING:RESOLVED` / `BLOCKING:CONFIRMED-UNKNOWN`
- **Option B:** `BLOCKER:RESOLVED` / `BLOCKER:CONFIRMED-UNKNOWN`
- **Option C/D:** Similar compound forms

**Recommendation:** Option B — `BLOCKER / WARNING / INFO`. Rationale:
- `BLOCKER` is the noun form used natively in GitHub, Linear, Jira, and most project tooling — engineers recognise it immediately without a definition
- `WARNING` is already the standard term in compilers, linters, CI output, and log levels
- `INFO` replaces `LOWRISK` — it drops the risk-assessment connotation (these are gaps, not risks) and aligns with the log-level tier structure (`ERROR / WARNING / INFO`) which is as widely understood as any vocabulary in software

The existing FC-2 decision record should be amended to update the labels only — the classification rules, behaviour, and terminal states remain identical. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

***

**Please confirm or redirect on each decision and I'll continue to Task 1.2.**

***

# Task 1.2 — Gap Classification: Full Subtask Analysis

Task 1.2's question: *which gaps are blocking and which can be surfaced as open questions?*  It receives the five classified outputs of Task 1.1 and applies the FC-2 taxonomy to produce the first entries in the shared open questions register — the persistent FC-8 record that travels through all six bootstrap steps. 

***

## Subtask 1 — Classify Each ABSENT or AMBIGUOUS Required Field

### What Is Happening

Each ABSENT or AMBIGUOUS required field from Task 1.1's Required Field Mapping (Subtask 2) is tested against the FC-2 classification rule: 

> *Would proceeding without this information, or getting it wrong, cause a subsequent step to fail or produce a materially incorrect output?*
> - YES → BLOCKER
> - NO → apply second test: does the absence have a known, specific downstream impact?
>   - YES → WARNING
>   - NO → INFO

Applied to our case study (ABSENT/AMBIGUOUS required fields only):

| Field | Task 1.1 Status | Classification Test | Classification |
|---|---|---|---|
| `techstack` — versions absent | AMBIGUOUS | Step 2's environment contract requires exact or minimum versions for `runtime.version` and `framework.version`. Without them, those fields either cannot be populated or must be invented — an FC-1 violation. | **BLOCKER** |
| `techstack` — React integration implicit | AMBIGUOUS | Step 2 cannot write a complete framework section if one stack dependency is undeclared. A missing adapter (`@astrojs/react`) means missing install commands, config entries, and version fields in the contract. | **BLOCKER** |
| `deploymenttarget` — Workers vs. Pages unclear | AMBIGUOUS | The entire deployment section of Step 2's environment contract is conditioned on this. A Workers contract and a Pages contract are structurally different documents. Proceeding with either assumption produces an incorrect contract. | **BLOCKER** |
| `devenvironment.runtime.version` — unknown | AMBIGUOUS | The human stated they don't know the version. Step 2 needs it for `runtime.version`. This is likely to become `BLOCKER:CONFIRMED-UNKNOWN` after clarification — the human genuinely may not know — but it's still a BLOCKER to attempt. | **BLOCKER** |
| `devenvironment.packagemanager` — ambiguous | AMBIGUOUS | Step 2's `runtime.packagemanager` and `runtime.installcommand` fields depend on this directly. "npm or pnpm" is not a valid contract value. | **BLOCKER** |
| `appetite` — informal value | AMBIGUOUS | `appetite` is a REQUIRED schema field. "Within a week" is present but doesn't match any valid enum value. Step 2 and Step 3 do not consume `appetite` directly, so the downstream step failure test returns NO. But see Gap note below. | **See gap ↓** |

### Skills Required to Do This to a High Standard

- **Step 2 schema knowledge** — the classifier must know what Step 2's environment contract needs, field by field, to assess whether a gap causes Step 2 to fail. This knowledge is not embedded in Task 1.2's description; it is a prerequisite competency
- **Worst-case reasoning** — the classification test is about what happens if the gap is not resolved; this requires imagining Step 2 executing with the gap in place, not imagining the most charitable resolution
- **Strict separation of classification from resolution** — the classifier must not simultaneously classify and propose an answer. "This is BLOCKER because Step 2 needs a version number; we should assume AstroJS 5.x" is two acts merged into one. Only the first belongs in Task 1.2
- **FC-1 awareness** — the classifier must recognise that any classification of a required field as non-BLOCKER must be grounded in evidence that Step 2 can proceed without it, not in the assumption that it will be resolved later

### Examples of Excellence

Classifying `techstack` versions as BLOCKER with the specific impact statement: *"Step 2 environment contract sections `framework.version` and `runtime.version` cannot be completed. Those fields require exact or minimum version values; populating them from assumed current-stable versions would violate FC-1."*

Treating the `appetite` enum mismatch as a separate and distinct classification question rather than collapsing it into the techstack issues — each field gets its own classification entry.

### Examples of Poor Performance

- Classifying `devenvironment.runtime.version` as WARNING because "Node.js version can be checked later during environment setup." This mistakes a deployment-time resolution for a contract-time requirement. Step 2 needs the version to write the contract, not to run the environment.
- Classifying `appetite` as non-BLOCKER and leaving it unaddressed — because it doesn't affect Step 2 or 3 — without flagging that it is a REQUIRED field that can't be left empty in the manifest.
- Writing compound classification entries: one entry for "techstack issues" covering versions, package manager, and React integration together. Each gap must be a separate entry in the open questions register with its own `questionid`, `field`, and `impact`. 

### Uncovered Questions / Gaps

**The classification test has a scope limit.** The FC-2 test asks whether the gap would cause "a subsequent step to fail."  Applied strictly, this means Step 2 or Step 3. But `appetite` is a REQUIRED field whose absence makes the manifest structurally incomplete — yet it has no direct bearing on Steps 2 or 3. The test as written would classify it as non-BLOCKER. But an empty REQUIRED field is an invalid manifest, and an invalid manifest fails DoD 3 (all required fields non-empty). 

**Resolution:** The classification test needs a third entry point:

> Is the field REQUIRED in the manifest schema and unable to be validly populated from the current brief?
> - YES → BLOCKER (the manifest cannot pass its DoD without it)

This is not covered by FC-2 and should be raised as an improvement to the cross-cutting policies.

**No guidance on AMBIGUOUS vs. ABSENT classification difference.** Both feed into the same downstream test, but AMBIGUOUS fields require a different question format than ABSENT ones. An ABSENT field needs: *"What is your X?"* An AMBIGUOUS field needs: *"You stated X — can you confirm whether you mean Y or Z?"* The policy doesn't distinguish these in the classification subtask or in FC-3's question formulation rules. 

### Opportunities to Improve the Step 1 Policy

- Add the third entry point to the FC-2 classification test: REQUIRED schema fields that cannot be validly populated are BLOCKER regardless of downstream step dependency.
- Explicitly distinguish ABSENT-triggered and AMBIGUOUS-triggered BLOCKER entries in the open questions register — they require different question structures in Task 1.3.

### Risks

- **Appetite field left as an empty REQUIRED field:** If classified as non-BLOCKER and no clarification is sought, the manifest either fails DoD 3 or the field is populated by inference — an FC-1 violation. Neither outcome is acceptable. 
- **Single BLOCKER entry for multiple gaps in one field:** If `techstack` generates one BLOCKER entry rather than separate entries for "AstroJS version," "React integration," and "package manager," Task 1.3 will ask one compound question and receive a compound answer that is difficult to individually attribute in the traceability record.

***

## Subtask 2 — Classify Each ABSENT Optional Field

### What Is Happening

Each ABSENT (and AMBIGUOUS) optional field is tested against the second and third tiers of FC-2: 

> Does the absence have a known, specific impact on the quality of any downstream output?
> - YES → WARNING
> - NO → INFO

Applied to the case study:

| Field | Task 1.1 Status | Classification | Reason |
|---|---|---|---|
| `constraints` | PRESENT | — | Not absent; no entry needed |
| `outofscope` | PRESENT | — | Not absent |
| `existingassets` | ABSENT | **INFO** | No downstream step uses existing assets in bootstrap; absence has no quality impact |
| `referenceexamples` | PRESENT | — | Not absent |
| `integrationrequirements` — Formspree tentative | AMBIGUOUS | **WARNING** | Step 2's services section requires a named integration. An unconfirmed provider means that section cannot be completed, or must be written as "TBD" — a known quality degradation |
| Infrastructure readiness (non-mappable — Cloudflare account, DNS) | Not in schema | **→ Non-mappable path** | See Task 1.1 Subtask 4 output; handled separately |

### Skills Required to Do This to a High Standard

- **Downstream quality reasoning** — distinguishing a gap that "might matter" from a gap with a *known, specific* downstream impact. The FC-2 standard requires specificity: "WARNING" is not "this could be a problem." It requires naming the downstream field or step that degrades.
- **Optional-field discipline** — the tendency to dismiss all optional field gaps as INFO because "they're optional." An optional field in the manifest schema is optional as input; once present, it becomes an input that downstream steps consume. Formspree being AMBIGUOUS is not optional to Step 2 — it's a gap with a concrete contract consequence.
- **Separation from resolution** — same as Subtask 1. Classifying Formspree as WARNING and simultaneously proposing "we'll use Formspree as the default" conflates classification with drafting.

### Examples of Excellence

Formspree classified as WARNING with the specific impact: *"Step 2 environment contract section `services.name`, `services.type`, and `services.integration` cannot be completed without a confirmed provider. These fields are REQUIRED in the services section when the tech stack references a third-party form handler. Downstream impact: if left as WARNING, the environment contract will have an open services section. This will carry forward to Step 3 (role configuration) where the integration scope of work cannot be defined."*

### Examples of Poor Performance

- Classifying Formspree as INFO because "it's just a form tool." The agent knows enough about the stack to know this is a concrete integration with real environment implications — downgrading it to INFO trades accuracy for brevity.
- Treating the `referenceexamples` field as fully PRESENT without noting that the quality descriptors (typography, whitespace) exceed the field's schema definition and are captured only in the non-mappable list. If those descriptors aren't carried forward, they silently disappear. Flagging this as INFO — *"design intent descriptors present but exceed reference example field schema; captured in non-mappable list; not carried into manifest"* — protects that signal.

### Uncovered Questions / Gaps

**The classification test for optional fields applies the same downstream impact question as for required fields, but with no "schema completeness" safety net.** For required fields, a REQUIRED field that can't be populated is BLOCKER regardless of downstream use. For optional fields, there is no equivalent floor. An optional field that is legally absent in the manifest but whose absence creates a known WARNING is handled correctly by the taxonomy — but there's no check for optional fields that become de facto required once the tech stack is known. In this project, `services` is an optional section *in general* but becomes conditionally required when the brief explicitly references a third-party form handler. The policy should state that conditional requirements surfaced by the tech stack declaration elevate optional fields to WARNING automatically.

### Opportunities to Improve the Step 1 Policy / FC-2

- Add a rule: when a tech stack declaration implies an optional section (services, performance targets, etc.), that section's fields are reclassified as WARNING-or-higher for this project. The manifest template should include this conditional logic as a lookup table.

### Risks

- **Formspree ambiguity lost:** If classified as INFO and not flagged at the human gate, Step 2 produces an incomplete environment contract without any signal that the services section is outstanding. The issue surfaces at Step 3 or later — by which point multiple downstream documents are affected.
- **Non-mappable items not entering the register:** Task 1.2 classifies fields that Task 1.1 mapped. Items in the non-mappable list (infrastructure readiness, maintainability requirement, design intent descriptors) have no field to classify against — so they risk falling through the gap between Subtask 2 (optional fields) and Subtask 3 (contradictions) without entering the open questions register. 

***

## Subtask 3 — Classify Each Contradiction as BLOCKER

### What Is Happening

Every contradiction surfaced in Task 1.1 Subtask 5 (Contradiction Review) is unconditionally classified as BLOCKER.  The policy is explicit: *"contradictions are never downgraded."* This subtask is a mechanical application of that rule — there is no classification decision to make, only a confirmation that each contradiction has a BLOCKER entry in the output gap list. 

Applied to the case study:

| Contradiction | BLOCKER entry |
|---|---|
| "Deploy to Cloudflare Workers" conflicts with "fully static — no server-side rendering" | **BLOCKER** — `deploymenttarget` and `constraints[static]`. Impact: entire Step 2 deployment section depends on resolution; the AstroJS output mode (`static` vs `server`) is determined by this. |

### Skills Required to Do This to a High Standard

- **No-downgrade discipline** — the most important skill in this subtask is resistance to the impulse to reason a contradiction into a non-problem. Technical knowledge creates pressure to resolve contradictions silently; the framework's invariant exists precisely to resist that pressure. 
- **Impact specificity** — even though the BLOCKER classification is automatic, the impact statement must be specific. A contradiction that affects two fields in two different steps needs an impact statement that names both.
- **Linkage to the related required field entry** — the Workers/static contradiction is also reflected in the `deploymenttarget` BLOCKER entry from Subtask 1. The open questions register should link these two entries so that Task 1.3 handles them in a single clarification exchange rather than producing two separate questions about the same underlying issue.

### Examples of Excellence

Creating a BLOCKER entry for the contradiction that explicitly references both affected fields (`deploymenttarget` and `constraints`), names the two competing interpretations without choosing between them (*"Cloudflare Workers (edge compute, requires `@astrojs/cloudflare` adapter in `server` or `hybrid` mode) vs. Cloudflare Pages (static hosting, compatible with `output: static`)"*), and links to the `deploymenttarget` BLOCKER entry from Subtask 1 with a note: *"Resolve these two BLOCKER entries with a single clarification question."*

### Examples of Poor Performance

- Creating a BLOCKER entry but writing the impact as: *"Contradiction between deployment target and static constraint — needs clarification."* This tells Task 1.3 that clarification is needed but not what the clarification must determine. Task 1.3 cannot formulate a precise question from a vague impact statement.
- Failing to link the contradiction BLOCKER to the related `deploymenttarget` BLOCKER — leading to Task 1.3 asking two separate questions that the human experiences as the same question asked twice.

### Uncovered Questions / Gaps

**The policy gives no guidance on contradictions between fields that span different manifest sections.** The Workers/static contradiction involves `deploymenttarget` (a required field) and an item in `constraints` (an optional field). It is clear these conflict, but the policy's contradiction-as-BLOCKER rule doesn't address whether the BLOCKER is assigned to the required field, the optional field, or both. In this case, `deploymenttarget` is the load-bearing field — Step 2 cannot proceed without a resolved deployment target. The `constraints[static]` entry, being optional, would normally not be a BLOCKER on its own. The contradiction elevates it. This interaction between field type and contradiction classification should be formalised.

**No guidance on how to handle contradictions that are only potential — requiring domain expertise to confirm.** Surfaced in the Task 1.1 analysis: the Workers/static case requires technical knowledge to identify as a contradiction. The policy assumes the classifier has this knowledge. For contradictions where the classifier is uncertain, there is no "potential contradiction" status — only BLOCKER or not. 

### Opportunities to Improve the Step 1 Policy

- Add a rule for linking related BLOCKER entries: when a contradiction involves the same field as an existing BLOCKER from Subtask 1, the contradiction entry must reference the Subtask 1 entry and Task 1.3 must consolidate them into a single clarification question.
- Add a `POTENTIAL-CONTRADICTION` classification for cases where technical domain knowledge is required to confirm a contradiction. This is classified as WARNING (not BLOCKER) until confirmed — but it is presented to the human alongside BLOCKER items with a note that it requires technical confirmation.

### Risks

- **Duplicate clarification questions:** Without linkage between the `deploymenttarget` BLOCKER (Subtask 1) and the Workers/static BLOCKER (Subtask 3), Task 1.3 asks Alex: *"Which Cloudflare product are you targeting?"* and separately: *"You stated the site must be fully static — do you mean no server-side rendering at all?"* These are the same question and the human recognises them as such. This damages trust in the process and produces a partial answer to each question instead of a complete answer to one. 
- **Technical contradictions passing through undetected:** If the classifier lacks the technical knowledge to identify the Workers/Pages distinction, the contradiction never enters the register. Step 2 then receives a manifest with `deploymenttarget: "Cloudflare Workers"` and `constraints: ["fully static"]` and must independently detect and handle the conflict — with no record of it having been identified. This is a broader risk of Task 1.1 Subtask 5, but it manifests in Task 1.2 as a silent classification gap.

***

## Cross-Cutting Observations for Task 1.2

### The Open Questions Register Is Born Here

Task 1.2 is the step that creates the FC-8 open questions register.  This is not stated in the Task 1.2 description — the policy says Task 1.2 produces "a two-tier gap list" but doesn't name it as the register's creation point. The policy should be explicit: Task 1.2's output IS the initial population of the open questions register, filed at `.framework/open-questions-register.md`. The "gap list" is not a separate intermediate document; it is the register. 

### The Non-Mappable List Has No Classification Path

Task 1.2's three subtasks cover required fields, optional fields, and contradictions. Non-mappable statements (from Task 1.1 Subtask 4) have no classification subtask. They fall through. This should be addressed by adding a fourth subtask to Task 1.2:

**Proposed Subtask 4:** *For each non-mappable statement, determine: (a) does it represent information that belongs in the manifest but has no current schema field? If yes, create a WARNING entry with a schema gap note. (b) Does it represent operational information with downstream consequences? If yes, create a WARNING or INFO entry referencing the relevant downstream step.*

This ensures that statements like "Cloudflare account is set up and DNS control is available" enter the register and eventually reach Step 2's environment contract rather than disappearing.

### The Classification Test Requires Step 2 and Step 3 Knowledge

The FC-2 classification test asks whether a gap causes a *subsequent step* to fail.  Applying this test correctly requires the Task 1.2 executor to know what Steps 2 and 3 need. This is a knowledge dependency that should be explicit in the policy — either as a required input (Step 2 and Step 3 policy documents as reference) or as a skill file entry that the executing agent loads. Without this knowledge, the executor is guessing, not classifying. 


# Task 1.2 — Gap Classification: Full Subtask Analysis

**Task 1.2's question:** Which gaps are blocking and which can be surfaced as open questions? [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

**Input:** `brief-inventory.yaml` from Task 1.1
**Output:** `open-questions-register.yaml` — initial population, created here, persisting through all six bootstrap steps per FC-8 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

*Standing instruction: read the complete input before producing any output.*

***

## Revised Subtask Structure

The policy's original three subtasks covered required fields, optional fields, and contradictions. Our Task 1.1 analysis surfaced a fourth category — non-mappable statements — that has no classification path in the original policy. Revised structure:

| # | Subtask | Source array in `brief-inventory.yaml` |
|---|---|---|
| 1 | Classify ABSENT/AMBIGUOUS required fields | `fields` where `required: true` and `coverage` is not PRESENT |
| 2 | Classify ABSENT/AMBIGUOUS optional fields | `fields` where `required: false` and `coverage` is not PRESENT |
| 3 | Classify contradictions | `contradictions` |
| 4 | Classify non-mappable statements | `non_mappable` |

***

## Subtask 1 — Classify ABSENT/AMBIGUOUS Required Fields

### What Is Happening

Each required field with coverage ABSENT or AMBIGUOUS is passed through the FC-2 classification test.  The test has three gates, applied in order: [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

> **Gate 1:** Would proceeding without this information, or getting it wrong, cause a subsequent step to fail or produce a materially incorrect output?
> - YES → **BLOCKER**
>
> **Gate 2:** Does the absence have a known, specific impact on the quality of any downstream output?
> - YES → **WARNING**
> - NO → **INFO**
>
> **Gate 3 (addition from Task 1.1 analysis):** Is this a REQUIRED schema field that cannot be validly populated from the current brief?
> - YES → **BLOCKER** regardless of Gates 1 and 2

Gate 3 is the new addition. Without it, `appetite` (REQUIRED, enum-constrained, no valid value in brief) would pass Gates 1 and 2 as non-BLOCKER — because Step 2 doesn't consume `appetite` directly. But a manifest with an empty REQUIRED field fails DoD 3. Gate 3 catches this. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

Applied to the case study required fields with non-PRESENT coverage:

| Field | Coverage | Gate reached | Classification | Impact statement |
|---|---|---|---|---|
| `techstack` — AstroJS version | AMBIGUOUS | Gate 1 YES | **BLOCKER** | Step 2 `framework.version` cannot be completed; populating from assumed current-stable is an FC-1 violation |
| `techstack` — React integration implicit | AMBIGUOUS | Gate 1 YES | **BLOCKER** | Step 2 install commands and config entries cannot be written for an undeclared dependency |
| `techstack` — package manager ambiguous | AMBIGUOUS | Gate 1 YES | **BLOCKER** | Step 2 `runtime.packagemanager` and `runtime.installcommand` require a single confirmed value |
| `deploymenttarget` — Workers vs Pages | AMBIGUOUS | Gate 1 YES | **BLOCKER** | Step 2 deployment section structure differs entirely between Workers and Pages; AstroJS output mode depends on resolution |
| `devenvironment.runtime.version` | AMBIGUOUS | Gate 1 YES | **BLOCKER** | Step 2 `runtime.version` requires an exact or minimum version; human stated they don't know |
| `appetite` — informal value | AMBIGUOUS | Gate 3 YES | **BLOCKER** | REQUIRED field; "within a week" is not a valid enum value; manifest fails DoD 3 without a valid entry |

Each becomes a separate entry in the register — not grouped by theme. Six BLOCKER entries from this subtask alone.

### Skills Required to Do This to a High Standard

- **Step 2 schema knowledge as a prerequisite** — Gate 1 cannot be applied without knowing what Step 2 needs, field by field. This is the most critical competency in this subtask and is not provided by the brief or the manifest schema alone. It must be loaded from an external reference — the Step 2 policy or an agent skill file. Without it, Gate 1 becomes guesswork.
- **One gap, one entry discipline** — `techstack` has three distinct gaps (version, React integration, package manager). Each has a different field association, a different impact statement, and will produce a different clarification question in Task 1.3. Collapsing them into one entry degrades every downstream task.
- **Gate 3 awareness** — recognising that REQUIRED field validity is an independent classification criterion, not covered by the downstream-failure test. An agent that only applies Gates 1 and 2 will miss the `appetite` case.
- **No resolution during classification** — the most common failure mode. Classifying `techstack` versions as BLOCKER and simultaneously noting "AstroJS latest stable is 5.x" is two acts. Only the classification belongs here.

### Examples of Excellence

Six separate register entries produced. Each has a specific `gap` (one sentence, one field, one missing piece), a specific `impact` (names the Step 2 field or DoD criterion that fails), and a source reference to the relevant statement ID(s) from `brief-inventory.yaml`. The `appetite` entry explicitly invokes Gate 3 in its impact statement so the reviewer can see why a field with no downstream step dependency is still BLOCKER.

### Examples of Poor Performance

- One entry for `techstack` reading: *"Technology stack is ambiguous — versions and configuration not fully specified."* This produces one clarification question in Task 1.3 that asks for everything at once. The human provides a paragraph-length answer. Task 1.4 (Manifest Drafting) then has to decompose that answer back into individual field values, re-establishing the structure that should have been created here.
- Classifying `appetite` as non-BLOCKER because "Step 2 doesn't use appetite" — Gate 3 not applied.
- Classifying `devenvironment.runtime.version` as WARNING because "the human can check later." The human stated they don't know the version. This is likely a `CONFIRMED-UNKNOWN` outcome from Task 1.3, but it must be attempted as BLOCKER first — the classification is not informed by the expected outcome of clarification.

### Uncovered Questions / Gaps

**Gate 1 requires knowledge this subtask's policy doesn't supply.** The test asks whether a gap causes "a subsequent step to fail." The executor needs to know Steps 2 and 3's requirements to answer this. The policy describes Task 1.2 as if this knowledge is implicit. It isn't. The Step 1 agent's context card or skill file must explicitly include the downstream step requirements as loaded reference material, and the policy should state this. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

**The AMBIGUOUS coverage status conflates two different gap types.** `techstack` versions are AMBIGUOUS because information is present but incomplete. `appetite` is AMBIGUOUS because information is present but in the wrong format. These require different question forms in Task 1.3: version gaps need *"what version?"* and format gaps need *"you said X — which of these valid values best matches?"* The policy doesn't distinguish them, but the open questions register should.

### Opportunities to Improve the Policy

- Add Gate 3 to the FC-2 classification rule in the cross-cutting policies.
- Add a `gap_type` field to the register: `ABSENT` (no information), `AMBIGUOUS-INCOMPLETE` (partial information), `AMBIGUOUS-FORMAT` (information present, wrong form). This shapes the question formulation in Task 1.3 without requiring Task 1.3 to re-derive the gap type.
- Make the downstream step knowledge dependency explicit in the policy: *"Applying Gate 1 requires the executor to have loaded the Step 2 and Step 3 policy documents as reference material."*

### Risks

- **Under-classification of `appetite`:** If Gate 3 is not applied, `appetite` produces no BLOCKER entry. Task 1.3 is never triggered for it. Task 1.4 populates the field by inference. The manifest fails DoD 5 (no invented values). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)
- **Gate 1 guessing:** An agent without Step 2 knowledge applies Gate 1 based on intuition. Some BLOCKERs are downgraded to WARNING. Step 2 then receives a manifest with unresolved gaps that were never flagged as blocking, producing either FC-1 violations or an incomplete environment contract.

***

## Subtask 2 — Classify ABSENT/AMBIGUOUS Optional Fields

### What Is Happening

Optional fields with non-PRESENT coverage are passed through Gates 2 and 3 only — Gate 1 is not applicable because optional fields are legally absent from the manifest.  The practical consequence: optional fields can only be WARNING or INFO, never BLOCKER. The exception is the **conditional requirement rule** surfaced in Task 1.1: when the tech stack declaration implies an optional section, that section's fields become WARNING automatically, regardless of the Gate 2 test result. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

Applied to the case study:

| Field | Coverage | Conditional? | Classification | Impact |
|---|---|---|---|---|
| `integrationrequirements` — Formspree tentative | AMBIGUOUS | YES — form handler referenced in brief | **WARNING** | Step 2 `services` section conditionally required when a third-party form handler is referenced; leaving unconfirmed produces an incomplete contract section |
| `existingassets` | ABSENT | NO | **INFO** | No downstream step requires existing assets in bootstrap; noted for completeness |
| `referenceexamples` descriptors | PRESENT (field) + non-mappable (descriptors) | NO | Handled in Subtask 4 | Design intent descriptors overflow schema; main field is PRESENT |

### Skills Required to Do This to a High Standard

- **Conditional requirement detection** — recognising when an optional field becomes functionally required given the specific tech stack. This requires knowing which manifest sections have conditional trigger rules (services section is triggered by third-party integrations, performance targets section is triggered by measurable performance constraints). These triggers should be enumerated in the manifest template's metadata, not left to the executor's judgment.
- **INFO ≠ ignorable** — INFO entries still enter the open questions register. They travel through all subsequent steps. They are presented to the human director at Step 6. The discipline is: INFO gaps are documented with the same rigour as BLOCKER gaps; they just don't trigger the clarification protocol.

### Examples of Excellence

The `integrationrequirements` entry clearly invokes the conditional requirement rule: *"Tech stack references a third-party form handler (brief statement S-08). This triggers the services section in the Step 2 environment contract. Provider name and integration method are REQUIRED within that section once it is triggered. Classification: WARNING — step proceeds, but Step 2 will have an incomplete services section unless this is resolved."*

### Examples of Poor Performance

Classifying Formspree as INFO because "it's not a required field." This is the conditional requirement blind spot — a field that is optional in general but mandatory given the specific brief context.

### Uncovered Questions / Gaps

**The conditional requirement triggers are not documented in the manifest template.** The executor has to know, from domain knowledge, that a referenced form handler triggers the services section. This belongs as metadata in the manifest template itself — a lookup table: *if `techstack` contains a form handler reference → `services` section required; if `constraints` contains a measurable performance target → `performance_targets` section required.* Without this, the conditional rule is applied inconsistently. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

### Opportunities to Improve the Policy

- Add a **conditional sections table** to the manifest template schema: tech stack patterns that trigger optional sections. This makes Subtask 2 a table lookup rather than a judgment call, and makes the results reproducible.

### Risks

- **Formspree ambiguity reaching Step 2 unclassified:** If not entered as WARNING here, Step 2 has no signal that the services section is expected. The contract is produced without it. This is a silent quality degradation that doesn't surface until someone tries to implement the contact form and discovers the integration was never specced.

***

## Subtask 3 — Classify Contradictions

### What Is Happening

Every entry in the `contradictions` array of `brief-inventory.yaml` receives an automatic BLOCKER classification. No test is applied — contradictions are never downgraded. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

This subtask has one additional operation beyond simple classification: **deduplication linking**. The Workers/static contradiction (C-01) involves `deploymenttarget` — the same field that already has a BLOCKER entry from Subtask 1. These two entries must be linked in the register so that Task 1.3 consolidates them into a single clarification question rather than asking about the same underlying issue twice.

```yaml
# Register entries after Subtask 3:

- questionid: OQ-1-05
  field: deploymenttarget
  gap: "Contradiction: 'Cloudflare Workers' conflicts with 'fully static — no server-side rendering'"
  impact: "AstroJS output mode and adapter selection depend entirely on resolution; Step 2 deployment section cannot be written until resolved"
  source_statements: [S-02, S-03]
  contradiction_ref: C-01
  classification: BLOCKER
  linked_questions: [OQ-1-04]  # links to the deploymenttarget BLOCKER from Subtask 1
  raisedbystep: 1
  currentowner: 1
  resolutionstatus: OPEN
```

The `linked_questions` field signals to Task 1.3: *"These two entries are related — ask one question, not two."*

### Skills Required to Do This to a High Standard

- **No-downgrade discipline** — resisting the urge to apply technical knowledge to resolve contradictions internally. The agent may know that Cloudflare Pages is the correct interpretation. That knowledge must not influence the classification or the register entry. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)
- **Deduplication detection** — cross-referencing the `affected_fields` in each contradiction entry against the entries already created in Subtasks 1 and 2. If any affected field already has a register entry, the linking relationship must be recorded.
- **Two-interpretation impact statements** — the impact statement for a contradiction BLOCKER must describe both competing interpretations and what each implies downstream, without choosing between them.

### Examples of Excellence

The register entry for C-01 names both interpretations: *"If Cloudflare Workers: requires `@astrojs/cloudflare` adapter, AstroJS output mode `server` or `hybrid`, edge function capability active — incompatible with static constraint. If Cloudflare Pages: AstroJS output mode `static`, no adapter required, contact form must use external handler only — consistent with static constraint."* Task 1.3 can translate this directly into a precise question.

### Examples of Poor Performance

- A contradiction entry with impact: *"Deployment target unclear — needs clarification."* Task 1.3 cannot formulate a useful question from this. It will ask something vague like *"Can you clarify your deployment preference?"* — which produces a vague answer.
- Not detecting that C-01 and the `deploymenttarget` BLOCKER from Subtask 1 are related. Task 1.3 asks two separate questions. The human responds to the first, Task 1.3 records it, then asks the second — which the human has already answered. This is a trust-damaging process failure.

### Uncovered Questions / Gaps

**`POTENTIAL-CONTRADICTION` status is still unresolved.** Our Task 1.1 analysis proposed a `POTENTIAL-CONTRADICTION` classification for technical contradictions that require domain expertise to confirm. The policy as written gives no path for this. The current design forces a binary: either it's a contradiction (BLOCKER) or it isn't (no entry). The correct approach for domain-knowledge-dependent contradictions is to classify them as **WARNING with a `contradiction_flag: true` annotation** — they enter the register, are presented at the human gate, but don't block drafting. This preserves the signal without over-blocking. This should be raised as an addition to FC-2.

### Opportunities to Improve the Policy

- Add `linked_questions` as a formal register field — not just noted in the entry text but a machine-readable array that Task 1.3 can directly query to detect consolidation opportunities.
- Add `POTENTIAL-CONTRADICTION` as a WARNING-level flag to FC-2, with the rule: *"Contradictions that can only be confirmed with domain expertise are classified as WARNING with `contradiction_flag: true`. They are escalated to BLOCKER if confirmed during clarification."*

### Risks

- **Duplicate questions in Task 1.3:** Without `linked_questions`, Task 1.3 treats every BLOCKER entry as independent. For this brief, that produces two questions about the deployment target. The human answers one. Task 1.3 records a partial answer. The second question is asked and the human reasonably pushes back on the process quality.

***

## Subtask 4 — Classify Non-Mappable Statements

### What Is Happening

This subtask is new — not present in the current Step 1 policy. Every entry in the `non_mappable` array of `brief-inventory.yaml` is assessed for downstream consequence and classified. The classification test is simpler than for fields:

> Does this statement represent information with a downstream consequence in Steps 2–6?
> - YES, consequence is specific and named → **WARNING**
> - YES, consequence is plausible but indirect → **INFO**
> - NO → **INFO** (noted for completeness; no register entry required unless it represents a schema gap)

Applied to the case study non-mappable statements:

| Statement | Text | Classification | Reason |
|---|---|---|---|
| S-13 | "Cloudflare account active, DNS control available" | **WARNING** | Step 2 deployment section has a field for deployment infrastructure readiness. Without this recorded, Step 2 cannot confirm DNS configuration is self-managed — it may assume procurement is needed. Specific downstream consequence. |
| S-16 | "Handoff to a developer friend later" | **INFO** | No Step 2–6 schema field captures maintainability requirements. Downstream consequence is plausible (code quality standards) but too indirect to specify. Noted; candidate for a future `constraints` entry or schema addition. |
| S-17 | Design intent descriptors (typography, whitespace) | **INFO** | No manifest field captures design intent. Step 4 (Pattern Seeding) would benefit but the connection is indirect. Noted for completeness. |

### Skills Required to Do This to a High Standard

- **Schema gap recognition** — distinguishing between *"this information has no schema field"* (a schema gap, potentially requiring a future field addition) and *"this information doesn't belong in the schema"* (genuinely out of scope for the manifest). S-13 (infrastructure readiness) is a schema gap. S-17 (typography descriptors) is not — it belongs in a design brief, not a project manifest.
- **Downstream step awareness** — same as Subtask 1, this requires knowing what Steps 2–6 need. S-13 is only classifiable as WARNING if the executor knows Step 2 includes an infrastructure readiness field.

### Examples of Excellence

Classifying S-13 as WARNING with: *"No manifest field exists for existing infrastructure readiness. This information is relevant to Step 2's deployment section. Entering as WARNING to ensure it is reviewed at the human gate and manually considered when drafting the Step 2 contract. Schema gap: candidate field `existingInfrastructure`."* This produces a useful register entry AND a schema improvement signal.

### Examples of Poor Performance

Not performing this subtask at all — the most common failure mode when subtasks are not explicitly mandatory. All three non-mappable statements disappear from the process. S-13 reaches Step 2 unrecorded. The Step 2 executor either invents an assumption about DNS management or produces a contract with an unacknowledged gap. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/96db4966-d6de-4410-8c55-10def23e562b/i-am-making-progress-in-creati-fuGLU8hCRLyka3xtBTVglA.md)

### Opportunities to Improve the Policy

- Add Subtask 4 to the Task 1.2 policy definition explicitly — it is currently absent.
- Add a `schema_gap_flag: true` field to the register for WARNING entries that represent missing schema fields. This creates a feedback loop: schema gaps accumulate in the register across projects and inform manifest template evolution.

***

## Output: `open-questions-register.yaml`

Task 1.2 creates this file. It is not a summary or intermediate document — it IS the output. Applied to the case study, the initial register has nine entries:

```yaml
# open-questions-register.yaml
# Created: Step 1, Task 1.2
# Persists through: Steps 1–6

questions:

  - questionid: OQ-1-01
    field: techstack
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "AstroJS version not specified"
    impact: "Step 2 framework.version cannot be completed without a specific or minimum version"
    source_statements: [S-04]
    classification: BLOCKER
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-02
    field: techstack
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "React integration implied by Shadcn dependency but not explicitly declared as a stack element"
    impact: "Step 2 cannot enumerate all dependencies for install commands and config entries"
    source_statements: [S-04]
    classification: BLOCKER
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-03
    field: techstack
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "Package manager unconfirmed — npm stated as default, pnpm cited as acceptable alternative"
    impact: "Step 2 runtime.packagemanager and runtime.installcommand require a single confirmed value"
    source_statements: [S-09]
    classification: BLOCKER
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-04
    field: deploymenttarget
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "Cloudflare Workers named but technical target may be Cloudflare Pages given static constraint"
    impact: "Step 2 deployment section structure differs entirely between Workers and Pages"
    source_statements: [S-02]
    classification: BLOCKER
    linked_questions: [OQ-1-05]
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-05
    field: deploymenttarget
    gap_type: CONTRADICTION
    gap: "Cloudflare Workers implies edge compute adapter incompatible with AstroJS output:static; static constraint requires output:static"
    impact: "AstroJS output mode and adapter selection cannot be determined; entire Step 2 deployment and framework sections blocked"
    source_statements: [S-02, S-03]
    contradiction_ref: C-01
    classification: BLOCKER
    linked_questions: [OQ-1-04]
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-06
    field: devenvironment
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "Node.js runtime version unknown — human stated they do not know the exact version"
    impact: "Step 2 runtime.version requires an exact or minimum version; field cannot be completed"
    source_statements: [S-11]
    classification: BLOCKER
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-07
    field: appetite
    gap_type: AMBIGUOUS-FORMAT
    gap: "Appetite stated as 'within a week' — not a valid enum value (valid: small/medium/large)"
    impact: "REQUIRED field cannot be validly populated; manifest fails DoD 3"
    source_statements: [S-15]
    classification: BLOCKER
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-08
    field: integrationrequirements
    gap_type: AMBIGUOUS-INCOMPLETE
    gap: "Form handler provider tentative — Formspree mentioned but not confirmed"
    impact: "Step 2 services section conditionally required when form handler referenced; provider name and integration method cannot be specified"
    source_statements: [S-08]
    classification: WARNING
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN

  - questionid: OQ-1-09
    field: null
    gap_type: SCHEMA-GAP
    gap: "Infrastructure readiness information present in brief but no manifest field exists"
    impact: "Step 2 deployment section may incorrectly assume DNS procurement is needed; self-managed DNS not formally recorded"
    source_statements: [S-13]
    classification: WARNING
    schema_gap_flag: true
    candidate_field: existingInfrastructure
    raisedbystep: 1
    currentowner: 1
    resolutionstatus: OPEN
```

***

## Done When

Task 1.2 is complete when:
1. Every `fields` entry in `brief-inventory.yaml` with coverage ABSENT or AMBIGUOUS has a corresponding register entry
2. Every `contradictions` entry has a BLOCKER register entry
3. Every `non_mappable` entry has been assessed and either has a register entry or has a documented reason for no entry
4. All BLOCKER entries involving the same field are linked via `linked_questions`
5. `open-questions-register.yaml` exists at the canonical path `.framework/open-questions-register.yaml`
6. All entries have `resolutionstatus: OPEN`

***

Decisions Made in Step 1 task analysis
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