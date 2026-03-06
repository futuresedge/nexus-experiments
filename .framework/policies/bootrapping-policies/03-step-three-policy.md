# Step 3 Policy: Role Configuration

**Version:** 0.1 — Draft
**Depends on:** Step 1 `project-manifest.md` in `APPROVED` status; Step 2 `environment-contract.md` in `ACCEPTED` status
**Blocks:** Step 4 (Knowledge Base Seeding) and Step 5 (End-to-End Verification) cannot begin until this step's output set is accepted

***

## Overview

Step 3 answers one question: *Does every role required to perform, review, and govern work on this project have a complete, project-specific definition?*

The toolkit contains base role definitions — generic templates that describe what each role type does. Those templates are not usable on a project. They must be instantiated: configured with this project's file paths, this project's tech stack references, and this project's document structure. A generic template that describes "where to write the task specification" is not the same as a definition that says "write to `.tasks/task-[id].md` in the petes-plumbing-site project."

This step produces that instantiated set. It also produces a context tree — the map of every document this project will generate, which role produces each one, and which roles read each one. The context tree makes two critical checks possible: no two roles claim write authority over the same document type, and no document type that the project needs is left without a designated writer.

Both individual and collective verification are required. A set of individually correct role definitions can still be collectively broken — if two definitions each claim write authority over the project manifest, both might pass individual inspection and the set fails as a system. Collective verification is not a second pass over the same checklist. It is a different check that individual inspection cannot perform.

This step has a higher structural significance than Steps 1 and 2. The role definitions produced here are the capability model for the entire project. Every action any role can take derives from what was configured here. A role that was given the wrong capability will use it. A role that was denied a needed capability will fail. Neither error is recoverable cheaply once delivery begins.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| `project-manifest.md` in `APPROVED` status | Step 1 output | **REQUIRED** | Hard blocker — project scope is undefined |
| `environment-contract.md` in `ACCEPTED` status | Step 2 output | **REQUIRED** | Hard blocker — tech stack context for role configuration is unverified |
| Base role templates (one per roster class) | Toolkit | **REQUIRED** | No starting point for any role definition |
| Base roster definition | Toolkit | **REQUIRED** | No authoritative list of which roles are required |
| Role design standards | Toolkit | **REQUIRED** | No criteria against which to verify individual definitions |
| Framework document taxonomy | Toolkit | **REQUIRED** | No basis for constructing the context tree |

### Detailed Input Specifications

#### `project-manifest.md`

| Criterion | Requirement |
|---|---|
| **Status** | Must be `APPROVED` |
| **Fields used** | `project_id`, `tech_stack`, `constraints`, `out_of_scope`, `human_actors`, `appetite` |
| **Tech stack specificity** | The same requirement as Step 2 — named technologies only. Category descriptions are not valid inputs for role configuration |
| **Human actors** | The `human_actors` list determines which human roles exist and what authority they hold. At minimum, one `human:director` must be declared. If `human:approver` is a different person from `human:director`, both must be declared — roles cannot be configured for authority they don't have |

#### `environment-contract.md`

| Criterion | Requirement |
|---|---|
| **Status** | Must be `ACCEPTED` — a `PENDING` or `RETURNED` contract is not a valid input |
| **Fields used** | `dev_environment`, `deployment`, `framework`, `constraints`, `services`, `verification` |
| **Purpose in this step** | Role definitions for execution and review roles must reference this project's specific build commands, file paths, and verification methods — these come from the contract, not from the manifest |

#### Base role templates

| Criterion | Requirement |
|---|---|
| **Format** | Structured role definition documents — one per class in the base roster |
| **Currency** | Must be the current toolkit version |
| **Completeness** | Must exist for every role in the base roster; a missing template for a required role is a `BLOCKING` gap — the role definition cannot be produced from invention |
| **Role** | Templates provide the structural skeleton; project-specific values must be supplied during instantiation. A template value that is not project-specific (e.g., the role type, the one-sentence description) is carried forward unchanged. A template value that is project-specific (e.g., file paths, knowledge references) must be replaced |

#### Base roster definition

| Criterion | Requirement |
|---|---|
| **Format** | Authoritative list of role classes with their types (EXECUTOR / REVIEWER / OWNER / ORCHESTRATOR) and their zone applicability |
| **Authority** | This is the single source of truth for which roles exist in the framework's model. The roster for a specific project is derived from this list — it is not determined by Step 3 |
| **MVP roster** | The minimum viable roster for any project includes all roles required for the complete work lifecycle. A project cannot omit a role from the MVP roster without a documented, approved exception |

#### Role design standards

| Criterion | Requirement |
|---|---|
| **Format** | Specification with numbered, independently verifiable tests — one test per structural requirement |
| **Coverage** | Must cover: naming conventions, role type indicators, capability allocation rules, separation of execution and verification, content constraints (no task-specific content, no governance metadata), and context tree reference validity |
| **Use** | Applied to each role definition individually in Task 3.4; provides the pass/fail criteria |

#### Framework document taxonomy

| Criterion | Requirement |
|---|---|
| **Format** | Authoritative list of every document type the framework's work lifecycle produces, with its canonical path pattern and the role type authorised to produce it |
| **Use** | Required for Task 3.2 (context tree construction) — without a complete taxonomy, the context tree cannot cover all document types the project will need |

***

## Outputs

### Summary

| Output | Requirement | If Absent or Incomplete |
|---|---|---|
| Project-specific role definition for every roster class | **REQUIRED** | BLOCKER — any missing definition leaves a role undeployable |
| All role definitions individually verified against design standards | **REQUIRED** | BLOCKER — unverified definitions may contain structural defects |
| Project context tree | **REQUIRED** | BLOCKER — set verification cannot be performed without it; Step 5 smoke test requires it |
| Set verification record (no overlaps, no gaps) | **REQUIRED** | BLOCKER — individual verification does not guarantee collective coherence |
| Set acceptance record with attribution and timestamp | **REQUIRED** | BLOCKER — no evidence the collective check was independently performed |

### Detailed Output Specifications

#### Project-specific role definition — schema

Each role definition is a structured document. Every field listed below must be present. Required fields must be non-empty.

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `role_name` | String | **REQUIRED** | PascalCase; conforms to the naming convention in the design standards; final component indicates role type (e.g., `Owner`, `Orchestrator`, or a doer-word for EXECUTOR/REVIEWER) |
| `role_type` | Enum | **REQUIRED** | One of: `OWNER`, `ORCHESTRATOR`, `EXECUTOR`, `REVIEWER` |
| `description` | String | **REQUIRED** | One sentence; active voice; describes what this role does, not what it is; derived from the base template |
| `user_invokable` | Boolean | **REQUIRED** | Derived from `role_type`: `true` for `OWNER` and `ORCHESTRATOR`; `false` for `EXECUTOR` and `REVIEWER`. Not a configurable value — determined by type |
| `capabilities` | List | **REQUIRED** | The complete set of capabilities this role holds on this project. Must include all universal capabilities. Must include role-scoped capabilities appropriate to role type. Must not include capabilities that belong to other roles' exclusive domains. Maximum content: 15 lines for the full definition document |
| `reads` | List | **REQUIRED** | Named project-specific document paths this role reads; no categories or wildcards; paths must exist in or be producible within this project's context tree |
| `writes` | List | **REQUIRED** | Named project-specific document paths this role produces. For `EXECUTOR`: exactly one document type. For `OWNER`: the domain documents it has write authority over. For `ORCHESTRATOR`: may be empty (orchestrators coordinate, not produce). For `REVIEWER`: the review verdict document only — never the document it reviews |
| `never` | List | **REQUIRED** | Documents this role is explicitly forbidden from accessing. Non-empty for every role. Must include the documents produced by any role this role reviews (T5 compliance) |
| `knowledge_reference` | String | **REQUIRED** | Reference to the role knowledge resource that defines how this role does its work. Must be a named resource that exists in the toolkit or project — not a description |
| `context_tree_ref` | String | **REQUIRED** | The node in this project's context tree where this role sits. Must be valid against the context tree produced in Task 3.2 |
| `certainty_threshold` | Decimal | **REQUIRED** | A value from 0.0 to 1.0. `REVIEWER` roles must be `0.9`. Other role types have a justified threshold declared in the class definition |
| `subagents` | List | Conditional | Required for `ORCHESTRATOR` roles; must contain at least two entries. Absent for all other role types. |
| `gate_authority` | Object | Conditional | Required for `OWNER` roles; declares what this Owner can approve, reject, and halt. Absent for other role types |

**Content constraints applied to every definition:**
- The definition must not contain task-specific content — any information that applies to one task but not all tasks of this type
- The definition must not contain file paths that are not project-specific document paths (i.e., no toolkit-internal paths)
- The definition must not contain governance metadata (version history, approval records)
- The full definition document must not exceed 15 content lines

#### Project context tree

The context tree is a map of this project's complete document landscape. It is not a file listing — it is a relationship map.

| Element | Requirement | Format |
|---|---|---|
| Document type entries | **REQUIRED** — one per document type the project produces | Each entry: document type name, canonical path pattern, designated writer role, authorised reader roles |
| Write authority map | **REQUIRED** | A derived view showing: for each document type, exactly one writer role. If any document type has zero writers or more than one writer, the context tree is incomplete or contains an overlap |
| Coverage assertion | **REQUIRED** | An explicit statement that every document type in the framework document taxonomy that applies to this project is represented in the context tree |
| Boundary declarations | **REQUIRED** | For each adjacent pair of roles that hand work between them: the document that constitutes the handoff, the producing role, and the consuming role |

#### Verification record for each role definition

Produced by the verifier in Task 3.4. Retained as evidence.

| Field | Requirement |
|---|---|
| Role name | The role definition being verified |
| Test results | One result per design standards test: `PASS` or `FAIL` |
| Evidence per test | Literal reference to the definition content that confirms the result — assertions are not evidence |
| Overall verdict | `PASS` (all tests pass) or `FAIL` (one or more tests fail) |
| Findings list | For `FAIL`: each failing test, the specific defect, and what is required to resolve it |
| Verifier identity | Who performed the verification |
| Timestamp | ISO 8601 datetime of the verdict |

#### Set verification record

Produced in Task 3.5. A separate record from the individual verification records.

| Field | Requirement |
|---|---|
| Write authority check | For every document type: confirms exactly one writer role; lists any violations |
| Coverage check | For every required document type: confirms a writer role exists; lists any gaps |
| Reference validity check | For every path or knowledge reference in any definition: confirms it exists in this project's context tree or toolkit |
| Boundary consistency check | For every role handoff boundary: confirms alignment between producing and consuming role definitions |
| Overall set verdict | `PASS` or `FAIL` |
| Findings list | For `FAIL`: each violation with the roles involved |
| Verifier identity | Must differ from the party that produced the role definitions |
| Timestamp | ISO 8601 datetime |

***

## Definition of Done

### Summary

Step 3 is done when all eight conditions are simultaneously true:

1. A project-specific role definition exists for every role in the confirmed roster
2. Every role definition individually passes all design standards tests
3. The project context tree exists and covers every document type the project requires
4. The write authority map confirms exactly one writer per document type — no overlaps
5. The coverage check confirms every required document type has a designated writer — no gaps
6. Every file path and knowledge reference in every definition is valid within this project's context tree
7. The set verification was performed by a party different from the one that produced the definitions
8. Both the individual verification records and the set verification record are on file with attribution and timestamps

### Unambiguous Requirement Breakdown

#### DoD 1 — A definition exists for every roster class

- The confirmed roster list from Task 3.1 is the authoritative reference
- One definition document exists per class, at the canonical path `[project-root]/.github/agents/[RoleName].agent.md`
- Each definition is non-empty
- **Fails if:** Any roster class has no corresponding definition file; any definition file is empty; any definition exists for a role class not in the confirmed roster (extraneous definitions are a scope violation)

#### DoD 2 — Every definition passes all design standards tests

- The verification record for each role exists
- Every test in the design standards suite has a `PASS` result for each role
- Evidence for each `PASS` result is specific — a test marked `PASS` with no evidence is not a passing result
- **Fails if:** Any definition has no verification record; any test has a `FAIL` result in any definition's record; any `PASS` result has no specific evidence; the verification record was produced by the same party that produced the definition

#### DoD 3 — Context tree exists and covers all required document types

- The context tree document exists at `[project-root]/.framework/context-tree.md`
- Every document type in the framework taxonomy that applies to this project is represented
- Each document type entry has: a designated writer role, authorised reader roles, and a canonical path pattern
- **Fails if:** The context tree is absent; any required document type from the taxonomy is missing; any entry has an empty writer field; path patterns are generic rather than project-specific

#### DoD 4 — Write authority map: exactly one writer per document type

- The write authority map derived from the context tree shows one and only one writer role per document type
- This is verified against the `writes` field of every role definition — if two definitions claim write authority for the same document type, this condition fails
- **Fails if:** Any document type has zero writer roles in the write authority map; any document type has two or more writer roles; the write authority map was not produced or is not on record

#### DoD 5 — Coverage: every required document type has a writer

- Every document type the project's work lifecycle requires is listed in the context tree with a designated writer
- The framework document taxonomy is the authoritative reference for what "required" means — not judgment at verification time
- **Fails if:** Any document type from the applicable taxonomy is absent from the context tree; any document type has a designated writer role that is not in the confirmed roster

#### DoD 6 — All references are valid for this project

- Every file path in any role definition's `reads`, `writes`, or `never` list is either present in the context tree (for project documents) or in the toolkit (for framework documents)
- Every knowledge reference points to a named resource that exists
- Every `context_tree_ref` value matches an entry in the context tree produced in Task 3.2
- **Fails if:** Any path in any definition does not correspond to a real location; any knowledge reference points to a resource that does not exist; any `context_tree_ref` value has no match in the context tree

#### DoD 7 — Set verification performed by a different party

- The identity in the set verification record's `verifier_identity` field differs from the identity of any party that produced role definitions in Task 3.3
- This is structural — it cannot be satisfied by the same party reviewing at a different time
- **Fails if:** The set verification record's verifier identity matches the producer; the set verification record is absent; `verifier_identity` is empty

#### DoD 8 — Both verification records are filed with attribution and timestamp

- Individual verification records exist for all roster classes, each with verifier identity and ISO 8601 timestamp
- The set verification record exists with verifier identity and ISO 8601 timestamp
- Records are retained at the canonical path `[project-root]/.framework/verification/`
- **Fails if:** Any individual verification record is missing; the set verification record is missing; any record lacks a verifier identity or timestamp; records are not at the canonical path

***

## Tasks

***

### Task 3.1 — Roster Confirmation

**Question:** Which roles are required for this project, and are there any exceptions to the base roster?

**Input:** Base roster definition from the toolkit; approved manifest (specifically `appetite`, `tech_stack`, `out_of_scope`)

**Output:** Confirmed roster list for this project — the base roster with any documented inclusions, exclusions, or deferrals; a rationale for any deviation from the base roster

**Subtasks:**
- Read the base roster and identify the MVP role set
- For each role in the base roster: confirm it is required for this project; note any that are marked optional in the toolkit
- Check whether the project's tech stack introduces any additional required roles not in the base roster (e.g., a stack-specific delivery reviewer) — if so, this is a framework-level gap, not a project-level decision (flag as F-item, do not add the role unilaterally)
- For `appetite: small` projects: confirm whether any MVP roles are marked as deferrable in the roster definition — if yes, document the deferral decision with rationale; if no, all MVP roles are required regardless of appetite
- Produce the confirmed roster as an ordered list: `REQUIRED`, `DEFERRED` (with rationale and conditions for activation), or `EXCLUDED` (with rationale and approval reference)

**One-way decision note:** Any exclusion from the MVP roster is an irreversible project-level decision — once the project begins delivery, a missing role definition cannot be created without going through the framework's role creation process. Flag any exclusions for `human:director` awareness before Step 3 proceeds. This is not a formal gate — it is a notification.

**Done when:** Every role in the base roster has a classification; any deviation from the base roster has a written rationale; the confirmed roster is the working reference for all subsequent tasks in this step

***

### Task 3.2 — Context Tree Construction

**Question:** What documents does this project produce, who produces each one, and who reads each one?

**Input:** Confirmed roster from Task 3.1; approved manifest; accepted environment contract; framework document taxonomy

**Output:** `context-tree.md` — the complete document relationship map for this project

**Subtasks:**
- Start from the framework document taxonomy and identify every document type that applies to this project
- Apply project-specific path patterns to each document type using:
  - `project_id` from the manifest (for path prefixes)
  - Tech stack values from the environment contract (for file extensions, config file names)
- For each document type: assign the writer role from the confirmed roster based on the taxonomy's role type assignment rules
- For each document type: list the reader roles from the confirmed roster
- Construct the write authority map: a lookup from document type → single writer role
- Construct the boundary map: for each role-to-role handoff, identify the document that constitutes the handoff and the direction of flow
- Identify any document type in the taxonomy with no writer role in the confirmed roster — this is a coverage gap and must be resolved before Task 3.3 begins (either the roster is missing a role, the taxonomy is wrong, or the project genuinely doesn't produce this document type)

**Done when:** Every applicable document type from the taxonomy has a project-specific path pattern, a single writer role, and a reader role list; the write authority map has no entries with zero or multiple writers; the context tree is expressed as a structured document at `[project-root]/.framework/context-tree.md`

***

### Task 3.3 — Role Definition Generation *(loop — one pass per roster class)*

**Question:** Does each base template produce a valid, project-specific definition when instantiated for this project?

**Input:** Base template for each role class; approved manifest; accepted environment contract; context tree from Task 3.2

**Output:** A project-specific role definition document for each roster class

**For each role in the confirmed roster:**

**Subtasks:**
- Open the base template for this role class
- Identify every field that contains a generic placeholder (path patterns, version references, knowledge resource names, context tree reference values)
- Replace each placeholder with the project-specific value:
  - File paths → project-specific paths from the context tree
  - Knowledge resource references → resources from the toolkit confirmed to exist
  - Context tree reference → the node from the context tree produced in Task 3.2
  - Tech stack references → values from the accepted environment contract
- Carry forward unchanged every field that is not project-specific: role name, role type, one-sentence description, certainty threshold, user-invocable setting
- For `ORCHESTRATOR` roles: verify the subagents list references role names that exist in the confirmed roster — if a subagent is listed that is deferred or excluded, resolve before writing
- For `OWNER` roles: verify gate authority declarations reference document types that exist in the context tree
- Apply content constraints: check that no task-specific content has been introduced; check that no governance metadata is present; check total line count does not exceed 15 content lines

**Self-check before completing each definition:**
- `context_tree_ref` matches an entry in the Task 3.2 context tree
- All paths in `reads` and `writes` are in the context tree or toolkit
- `never` list is non-empty
- The role does not appear in its own `reads` list for documents it produces (cannot read its own output from a prior run)
- For `REVIEWER` roles: certainty threshold is `0.9`; `writes` contains only the review verdict document; `never` contains all documents the corresponding `EXECUTOR` can write

**Done when (per definition):** All template fields have been replaced with project-specific values; content constraints are met; definition is saved at the canonical path; no value was invented — every replacement traces to the manifest, contract, or context tree

**This task loops across all roster classes.** Definitions may be produced in parallel where the roles are independent. Roles with dependencies (a reviewer definition depends on the executor definition being final) must be sequenced.

***

### Task 3.4 — Individual Verification *(loop — one pass per definition)*

**Question:** Does each role definition conform to every requirement in the design standards?

**Input:** Each role definition from Task 3.3; design standards test suite

**Output:** A verification record per role definition — `PASS` or `FAIL` with evidence

**This task is performed by a different party from the one that produced the definitions.**

**For each definition:**

**Subtasks:**
- Run every test in the design standards suite against the definition
- For each test: record `PASS` or `FAIL` with literal evidence from the definition content
- `PASS` without evidence is not valid — the evidence is the proof
- Produce the verdict: `PASS ALL` if all tests pass; `FAIL` with the failing test list if any test fails
- For `FAIL`: each finding specifies the failing test, the specific defect in the definition, and what change would resolve it — findings describe problems, not solutions

**If `FAIL`:** The definition returns to Task 3.3 with the findings record attached. Task 3.3 addresses each finding and produces a revised definition. Task 3.4 runs again on the revised definition. This loops until `PASS ALL`.

**Done when (per definition):** `PASS ALL` verdict recorded; verification record filed with verifier identity and timestamp; verifier identity differs from definition producer

***

### Task 3.5 — Set Verification

**Question:** Does the complete set of individually verified definitions form a coherent, gap-free, overlap-free capability model for this project?

**Input:** All individually verified (`PASS ALL`) role definitions; context tree from Task 3.2

**Output:** Set verification record — `PASS` or `FAIL` with findings

**This task is performed by a different party from the one that produced the definitions.**

**Subtasks:**

*Write authority overlap check:*
- For every document type in the context tree: collect every role that claims write authority in its `writes` field
- If any document type has more than one claiming role: `FAIL` — write authority conflict
- If any document type has zero claiming roles: `FAIL` — coverage gap

*Coverage gap check:*
- Compare the context tree's document type list against the framework document taxonomy's applicable entries
- If any required document type from the taxonomy is absent from the context tree: `FAIL` — taxonomy coverage gap
- If any document type has a writer role not in the confirmed roster: `FAIL` — orphaned authority

*Reference validity check:*
- For every path in every definition's `reads`, `writes`, or `never`: confirm the path exists in the context tree or toolkit
- For every knowledge reference: confirm the resource exists
- For every `context_tree_ref`: confirm it matches an entry in the context tree
- Any reference that does not resolve: `FAIL` — broken reference

*T5 compliance check (separation of execution and verification):*
- For each `EXECUTOR` / `REVIEWER` pair that share a domain: confirm the `REVIEWER`'s `never` list contains all document types the `EXECUTOR`'s `writes` list contains
- Confirm no `REVIEWER` holds write authority over documents it reviews
- Any violation: `FAIL` — T5 broken

*Verdict:*
- `PASS`: all four checks clear — record with verifier identity and timestamp
- `FAIL`: findings list specifying each violation (roles involved, document type affected, check category) — the set returns to Task 3.3 for targeted correction; only the affected definitions need revision; after correction, individual verification (Task 3.4) runs for revised definitions only, then set verification (Task 3.5) runs again

**Done when:** `PASS` verdict recorded in the set verification record; verifier identity differs from definition producer; timestamp present

***

### Task 3.6 — Step Completion Record

**Question:** Is the complete evidence package in place to confirm Step 3 is done?

**Input:** All individual verification records; set verification record; confirmed roster; context tree

**Output:** Step 3 completion entry in the project's bootstrap record — a structured summary of: roster confirmed (N roles), all definitions verified (N/N), set verification passed, context tree coverage confirmed (N document types)

**This task is administrative, not evaluative.** It does not perform any verification — it assembles the evidence that DoD 1–8 are met into a single addressable record for use in Step 5.

**Done when:** The completion record references all required evidence; every DoD condition can be traced to a specific record; the entry is timestamped and attributed

***

## Items to Flag for Higher-Level Consideration

**F10 — The Context Tree as a First-Class Artefact**
The context tree is produced in Step 3 but consumed in Steps 4 and 5. It is also the document against which role definition references are validated — it cannot be produced after the definitions that reference it. Its production must precede definition generation within Step 3. More significantly: the context tree may need to be a stable, versioned artefact with its own governance, not just an intermediate work product. This belongs at framework level.

**F11 — Roster Deviation Governance**
Task 3.1 identifies that any deviation from the base MVP roster is a one-way decision with downstream consequences. The current policy notifies `human:director` without requiring explicit approval. Whether roster deviations require a formal gate — especially exclusions — is a framework-level governance decision that Step 3 policy cannot settle alone.

**F12 — The Parallel Generation Constraint**
Task 3.3 notes that definitions can be generated in parallel for independent roles, but must be sequenced for role pairs with dependencies (EXECUTOR before the REVIEWER that reviews it). The dependency rules for role definition generation are implicit in the design standards but not explicit as a sequencing policy. A generation dependency map — which roles must be defined before which other roles — belongs at framework level.

**F13 — The Individual vs. Set Verification Boundary**
Steps 1 and 2 each have one verifier. Step 3 introduces two distinct verification acts: individual (each definition against design standards) and set (the complete set for coherence). These may be performed by the same verifier or different verifiers — but the framework needs to decide which. If the same verifier performs both, can they satisfactorily separate the acts? If different verifiers, the handoff protocol needs defining. This is a framework-level decision.

**F14 — Design Standards as a Living Document**
The design standards test suite is used as the verification instrument in Task 3.4. If the standards change after role definitions are produced, the definitions may no longer pass. A versioning and backwards-compatibility policy for the design standards — and what triggers re-verification of existing definitions — belongs at framework level.