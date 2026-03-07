# Step 2 Policy: Environment Specification

- **Version:** 0.1 — Draft
- **Depends on:** Step 1 `project-manifest.md` in `APPROVED` status
- **Blocks:** Step 3 (Role Configuration) cannot begin until this step's output is accepted

***

## Overview

Step 2 answers one question: *What must be true about the environment for work to succeed?*

The approved project manifest contains a tech stack declaration — named technologies, a deployment target, and a development environment description. This step translates that declaration into a complete, verifiable environment contract. Every statement in the contract must be testable. If a claim about the environment cannot be checked by running a command or inspecting a file, it is not a valid contract entry — it is an aspiration, and aspirations do not belong in a contract.

The contract produced here becomes the canonical environmental reference for the entire project. Every downstream decision that touches the environment — how agents configure their work, how proof of completion is verified, how deployment is checked — traces back to this document. An incomplete or unverifiable contract creates silent assumptions that only surface as failures during delivery.

This step has two parties by design: one produces the contract, a different one verifies it. The verifier's job is not to improve the contract — it is to confirm that every claim is internally consistent and independently checkable.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| `project-manifest.md` in `APPROVED` status | Step 1 output | **REQUIRED** | Hard blocker — Step 2 cannot begin |
| Environment contract template | Toolkit | **REQUIRED** | No schema to structure the output against; available by default |
| Tech stack knowledge base | Toolkit / available knowledge | **REQUIRED** | Required fields per stack type cannot be determined |
| Feedback channel to `human:director` | Process capability | **REQUIRED** | Blocking gaps in the manifest's tech stack declaration cannot be resolved |

### Information Required Within the Manifest

Step 2 reads the manifest and works from the following fields. Their completeness directly determines whether Step 2 can complete without clarification.

| Manifest field | Requirement | If absent or ambiguous |
|---|---|---|
| `tech_stack` | **REQUIRED** | BLOCKING — no basis for any contract section |
| `deployment_target` | **REQUIRED** | BLOCKING — deployment section cannot be written |
| `dev_environment` | **REQUIRED** | BLOCKING — local verification section cannot be written |
| `constraints` | OPTIONAL | WARNING — constraint-derived contract entries may be missing |
| `out_of_scope` | OPTIONAL | LOW RISK — no direct contract impact; noted |
| `open_questions` | Informational | Any tech-stack-related open questions from Step 1 carry forward as pre-identified gaps |

### Detailed Input Specifications

#### `project-manifest.md`

| Criterion | Requirement |
|---|---|
| **Status** | Must be `APPROVED` — a `DRAFT` manifest is not a valid input |
| **Version** | Must be the current version — not a prior draft |
| **Tech stack specificity** | Named technologies are valid inputs; category descriptions (`modern frontend stack`) are not. If the manifest contains category descriptions, they are `BLOCKING` gaps requiring clarification before the contract can be written |
| **Version information** | If a technology was declared without a version number (carried as an `open_question` from Step 1), the contract must either obtain the version through clarification or document the gap explicitly — the contract cannot silently assume a version |

#### Environment contract template

| Criterion | Requirement |
|---|---|
| **Format** | Markdown with explicitly labelled required and optional sections per stack type |
| **Stack-type sections** | The template defines which sections apply to which stack types — the contract must include all sections that apply to the declared stack and omit sections that do not |
| **Currency** | Must be the current toolkit version |

#### Tech stack knowledge base

The contract cannot be written from the manifest alone. Correctly specifying an AstroJS project requires knowing: that `astro.config.mjs` is the configuration file, that `output` mode (`static` | `server` | `hybrid`) is a required field, that the Netlify adapter is a distinct dependency from the Netlify deployment target, and that the relevant build output directory is `dist`. This knowledge is not in the manifest — it comes from the toolkit's knowledge base for the declared stack type.

| Criterion | Requirement |
|---|---|
| **Coverage** | The knowledge base must contain entries for each technology in `tech_stack` |
| **Currency** | Entries must correspond to the declared versions where versions are known |
| **Gap behaviour** | If the knowledge base has no entry for a declared technology, this is a `BLOCKING` gap — the contract for that technology cannot be written from invention |

***

## Outputs

### Summary

| Output | Requirement | If Absent or Incomplete |
|---|---|---|
| `environment-contract.md` accepted by the verifier | **REQUIRED** | BLOCKER — Step 2 is not done |
| All required sections present and non-empty | **REQUIRED** | BLOCKER — contract is structurally incomplete |
| Every claim paired with a verification method | **REQUIRED** | BLOCKER — unverifiable claims are not valid contract entries |
| Internal consistency confirmed | **REQUIRED** | BLOCKER — conflicting entries invalidate the contract as a reference |
| `open_questions` for all unresolved gaps | **REQUIRED** | WARNING — gaps will surface uncontrolled in Steps 3–5 |
| Verifier's acceptance record | **REQUIRED** | BLOCKER — no evidence the contract was independently checked |

### Detailed Output Specifications

#### `environment-contract.md` — schema

Every section listed below that applies to the declared stack must be present. Required fields within sections must be non-empty. Optional fields must be present in the document even if empty.

**Universal section** — required for all projects:

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `project_id` | String | **REQUIRED** | Must match `project_id` in the approved manifest exactly |
| `contract_version` | String | **REQUIRED** | `1.0` on first write; increments on each accepted revision |
| `last_updated` | ISO 8601 datetime | **REQUIRED** | Set at each revision |
| `review_status` | Enum | **REQUIRED** | `PENDING` on creation; `ACCEPTED` only when the verifier records acceptance; `RETURNED` if the verifier returns it |
| `reviewed_by` | String | Conditional | Required when `review_status = ACCEPTED`. Must identify the verifier |

**Runtime section** — required for all projects:

| Field | Requirement | Format / example |
|---|---|---|
| `runtime.name` | **REQUIRED** | e.g., `Node`, `Python`, `Ruby` |
| `runtime.version` | **REQUIRED** | Exact version or minimum version; if unknown from manifest, must be a documented open question — not assumed |
| `runtime.version_command` | **REQUIRED** | The command that confirms the runtime version in the actual environment, e.g., `node --version` |
| `runtime.package_manager` | **REQUIRED** | e.g., `pnpm`, `npm`, `pip` |
| `runtime.install_command` | **REQUIRED** | e.g., `pnpm install` |

**Repository and branching section** — required for all projects:

| Field | Requirement | Format / example |
|---|---|---|
| `repository.vcs` | **REQUIRED** | e.g., `git` |
| `repository.main_branch` | **REQUIRED** | e.g., `main`, `master` |
| `repository.branch_strategy` | **REQUIRED** | e.g., `feature branches off main` |

**Development environment section** — required for all projects:

| Field | Requirement | Format / example |
|---|---|---|
| `dev_environment.os` | **REQUIRED** | e.g., `macOS`, `Linux`, `Windows` — from manifest `dev_environment` |
| `dev_environment.editor` | OPTIONAL | e.g., `VS Code` |
| `dev_environment.start_command` | **REQUIRED** | The command to start the local development server |
| `dev_environment.local_port` | **REQUIRED** | e.g., `4321` |
| `dev_environment.build_command` | **REQUIRED** | The command to build for production |
| `dev_environment.build_output_dir` | **REQUIRED** | e.g., `dist` |

**Verification section** — required for all projects:

| Field | Requirement | Format / example |
|---|---|---|
| `verification.local_check` | **REQUIRED** | An executable command or exact sequence of steps that confirms the local build succeeds and the environment is correctly configured. Must produce an unambiguous pass/fail result. |
| `verification.deployed_check` | **REQUIRED** | An executable command or observable output that confirms the deployment succeeded and the environment contract is met in the deployed environment. |

**Framework section** — required when `tech_stack` includes a web framework (AstroJS, Next.js, etc.):

| Field | Requirement | Format / example |
|---|---|---|
| `framework.name` | **REQUIRED** | e.g., `AstroJS` |
| `framework.version` | **REQUIRED** | Exact or minimum; if unknown, documented open question |
| `framework.config_file` | **REQUIRED** | e.g., `astro.config.mjs` |
| `framework.output_mode` | **REQUIRED** (static site frameworks) | e.g., `static`, `server`, `hybrid` |

**Styling section** — required when `tech_stack` includes a CSS framework:

| Field | Requirement |
|---|---|
| `styling.name` | **REQUIRED** |
| `styling.version` | **REQUIRED** or documented open question |
| `styling.config_file` | **REQUIRED** if a config file exists for this framework |

**Deployment section** — required for all projects:

| Field | Requirement | Format / example |
|---|---|---|
| `deployment.provider` | **REQUIRED** | e.g., `Netlify`, `Vercel`, `AWS` |
| `deployment.deploy_trigger` | **REQUIRED** | e.g., `git push to main`, `manual CI workflow` |
| `deployment.production_url` | **REQUIRED** | Full URL or `not yet assigned` — never left empty |
| `deployment.staging_url` | **REQUIRED** | Full URL, `not configured`, or `not applicable` — never left empty |
| `deployment.build_command` | **REQUIRED** | The build command as used by the deploy provider — may differ from the local build command |
| `deployment.publish_dir` | **REQUIRED** | The directory the provider deploys from, e.g., `dist` |
| `deployment.env_vars` | **REQUIRED** | List of required environment variable *names* only — never values. Empty list `[]` is valid if none required |

**Constraints section** — required when `constraints` is non-empty in the manifest:

| Field | Requirement | Format / example |
|---|---|---|
| `constraints` | List of objects | Each entry: `name` (e.g., `no-react`), `description` (what it rules out), `testable_as` (how this constraint is verified) |

**Services section** — required when `tech_stack` or manifest references third-party services:

| Field | Requirement | Format / example |
|---|---|---|
| `services[].name` | **REQUIRED** | e.g., `Netlify Forms` |
| `services[].type` | **REQUIRED** | e.g., `forms`, `analytics`, `auth` |
| `services[].integration` | **REQUIRED** | How it's integrated, e.g., `HTML form attribute` |
| `services[].local_mock` | **REQUIRED** | `true` / `false` — can this service be used in local development? |

**Performance targets section** — required when `constraints` includes measurable performance targets:

| Field | Requirement | Format / example |
|---|---|---|
| `performance.targets[].metric` | **REQUIRED** | e.g., `Lighthouse Performance` |
| `performance.targets[].threshold` | **REQUIRED** | e.g., `90` |
| `performance.targets[].measurement_command` | **REQUIRED** | The exact command used to measure this metric — must produce a numeric result |

**Open questions** — required when any gap exists:

| Field | Requirement | Format |
|---|---|---|
| `open_questions` | List — present even if empty | Each entry: `field`, `gap`, `impact_if_unresolved`, `classification` (`BLOCKING` / `WARNING` / `LOW_RISK`) |

#### Verifiability rule — applied to every claim

Before any field is written as final, apply this test: *Can someone run a command or open a specific file and confirm this claim independently?*

| Verifiable | Not verifiable |
|---|---|
| `build_command: pnpm build` — run it; exit code 0 confirms it | `build_command: fast` — no command confirms "fast" |
| `runtime.version: 22.x` — run `node --version` | `runtime: latest` — "latest" is not a version |
| `local_port: 4321` — start dev server; confirm port in browser | `local_port: default` — "default" requires knowing the default |
| `output_mode: static` — read `astro.config.mjs` | `output_mode: recommended` — "recommended" is not a value |

A field that fails this test must either be made specific enough to pass it, or removed and replaced with an `open_questions` entry. There is no third option.

***

## Definition of Done

### Summary

Step 2 is done when all seven conditions are simultaneously true:

1. `environment-contract.md` exists at the canonical path
2. All sections required by the declared tech stack are present and non-empty
3. Every claim in the contract has a paired verification method that produces an unambiguous pass/fail result
4. The contract is internally consistent — no two entries contradict each other
5. `project_id` in the contract matches `project_id` in the approved manifest exactly
6. The verifier has reviewed the contract and recorded an `ACCEPTED` verdict with timestamp and attribution
7. The verifier is not the same party that produced the contract

### Unambiguous Requirement Breakdown

#### DoD 1 — File exists at canonical path

- The file exists at `[project-root]/.framework/environment-contract.md`
- The file is not empty
- The file is valid markdown
- **Fails if:** file is missing, at a different path, or empty

#### DoD 2 — All required sections present and non-empty

- Every section that applies to the declared stack is present
- Stack applicability is determined by the tech stack knowledge base, not by judgment at writing time
- Within each required section, every required field is non-empty
- Version fields that were genuinely unknown from the manifest appear in `open_questions`, not as empty fields or placeholder text
- **Fails if:** A section required by the stack type is absent; a required field within a present section is empty; a version field contains a non-specific placeholder like `latest`, `any`, or `TBD`

#### DoD 3 — Every claim has a paired verification method

- For every factual claim in the contract (a command, a version, a URL, a configuration value), there is a corresponding entry in `verification.local_check` or `verification.deployed_check` that tests it, OR the field itself specifies `version_command` or `measurement_command`
- The verification method produces a result that is unambiguous — pass or fail — without requiring judgment to interpret
- **Fails if:** Any factual claim has no corresponding verification method; any verification method is expressed as "check if it works" or equivalent non-specific language; any performance target lacks a `measurement_command`

#### DoD 4 — Internal consistency

- No two fields contain contradictory values
- The `deployment.build_command` is compatible with the `framework.output_mode` — a `static` output mode with a server-rendering build command is a contradiction
- The `deployment.publish_dir` matches what the framework's build command actually produces
- `project_id` in the contract matches `project_id` in the manifest
- **Fails if:** Any pair of fields produce contradictory constraints; a claim in one section makes a different claim in another section about the same variable impossible

#### DoD 5 — Project ID match

- `project_id` in the contract is character-for-character identical to `project_id` in the approved manifest
- **Fails if:** The values differ by any character, including case, spacing, or punctuation

#### DoD 6 — Verifier acceptance is recorded

- A record exists of the verifier's `ACCEPTED` verdict
- The record contains: the verifier's identity, the datetime of the verdict (ISO 8601 with timezone), and a reference to the contract version reviewed
- `review_status` in the contract is set to `ACCEPTED`
- `reviewed_by` identifies the verifier
- **Fails if:** No acceptance record exists; `review_status` is not `ACCEPTED`; `reviewed_by` is empty; the record contains `ACCEPTED` with no timestamp

#### DoD 7 — Producer and verifier are separate

- The party that wrote the contract and the party that verified it are structurally different
- This is not satisfied by the same party reviewing their own work at a different time
- **Fails if:** The verifier and the producer are the same entity

***

## Tasks

***

### Task 2.1 — Stack Classification

**Question:** Which contract sections are required for this declared tech stack?

**Input:** Approved `project-manifest.md` (specifically `tech_stack`, `deployment_target`, `dev_environment`, `constraints`); environment contract template; tech stack knowledge base

**Output:** A section activation list — every section in the template classified as `REQUIRED`, `NOT_APPLICABLE`, or `UNCERTAIN` for this project; any gaps where the manifest's tech stack declaration is insufficient to make the classification

**Subtasks:**
- Read `tech_stack` from the manifest
- For each technology: look up the corresponding knowledge base entry to identify which contract sections it activates
- For each manifest constraint: determine if it activates a contract section (e.g., a Lighthouse threshold activates the performance targets section)
- Classify each template section
- Identify any `UNCERTAIN` classification where the manifest's declaration is ambiguous — e.g., `Netlify` declared in `tech_stack` but unclear whether as a deployment target or CDN

**Done when:** Every template section has a classification; `UNCERTAIN` items are documented as gaps for Task 2.2

***

### Task 2.2 — Gap Analysis and Clarification Resolution *(conditional)*

**Question:** Is there sufficient information in the manifest to write every required section?

**Input:** Section activation list from Task 2.1; approved manifest; `open_questions` carried forward from Step 1; feedback channel to `human:director`

**Output:** A complete specification map — every required field in every required section either has a source value from the manifest, or has a `BLOCKING` gap with a recorded clarification answer, or has a documented `OPEN_QUESTION`

**Subtasks:**
- For each required section field: identify the manifest source for its value
- For each field with no manifest source: apply the classification test — *would leaving this unknown cause the contract to be unverifiable?* If yes: `BLOCKING`. If no: `OPEN_QUESTION`
- For `BLOCKING` gaps: raise a clarification question to `human:director` following the clarification protocol (one question per item, recorded with timestamp)
- Version numbers absent from the manifest are `BLOCKING` for the contract — a contract cannot be verified against `version: unknown`
- Carry forward any tech-stack-related `open_questions` from Step 1 and reclassify against the contract context — some may upgrade from `WARNING` to `BLOCKING` now that specific contract fields are known

**This task may loop** for each clarification exchange. Exit condition: no remaining `BLOCKING` gaps without a resolved value or confirmed-unknown status.

**Done when:** Every required field either has a source value, a resolved clarification answer, or a confirmed-unknown `OPEN_QUESTION` entry

***

### Task 2.3 — Contract Drafting

**Question:** Can all confirmed values be written into a valid, verifiable contract?

**Input:** Section activation list (2.1); specification map with resolved values (2.2); environment contract template; tech stack knowledge base

**Output:** `environment-contract.md` with `review_status: PENDING`

**Subtasks:**
- For each activated section: populate all required fields using confirmed values
- For each field: apply the verifiability rule before writing — if the value is not verifiable, resolve it or replace with an `open_questions` entry
- For each constraint in the manifest: write a corresponding constraints entry with `name`, `description`, and `testable_as`
- Write `verification.local_check` as an executable sequence — not a description, but actual commands that can be run
- Write `verification.deployed_check` as an observable output or command — testable against the actual deployed environment
- Set `review_status: PENDING`
- Set `contract_version: 1.0`
- Set `last_updated` to current datetime

**Self-check before completing:**
- `project_id` matches the manifest exactly
- Every required field in every activated section is non-empty
- No field contains a non-specific placeholder (`latest`, `TBD`, `default`, `standard`)
- `verification.local_check` can be executed as written — no steps requiring interpretation
- No constraint entry has an empty `testable_as` field
- `review_status` is `PENDING`

**Done when:** Contract is structurally complete, all fields are verifiable, `review_status: PENDING`

***

### Task 2.4 — Independent Verification

**Question:** Is the contract internally consistent, complete, and does every claim have a working verification method?

**Input:** `environment-contract.md` with `review_status: PENDING`

**Output:** `ACCEPTED` contract or `RETURNED` contract with a specific findings list

**This task is performed by the verifier — a different party from the drafter.**

**Subtasks:**

*Completeness check:*
- Confirm every section required by the declared stack is present
- Confirm every required field within each section is non-empty
- Confirm `project_id` matches the manifest

*Verifiability check — for each field:*
- Is the value specific enough to be independently confirmed?
- Does the `verification.local_check` sequence test the things it claims to test?
- Does the `verification.deployed_check` produce an observable, unambiguous result?
- Does each performance target have a `measurement_command` that produces a numeric result?

*Consistency check:*
- Does `deployment.build_command` produce output compatible with `deployment.publish_dir`?
- Does `framework.output_mode` match what the deployment configuration expects?
- Does `deployment.build_command` match or appropriately differ from `dev_environment.build_command` — and if it differs, is that difference explained?
- Are all declared constraints reflected somewhere in the contract body?

*Verdict:*
- `ACCEPTED`: all checks pass — set `review_status: ACCEPTED`, `reviewed_by: [verifier identity]`, timestamp
- `RETURNED`: one or more checks fail — produce a findings list; each finding specifies the field, the failure, and what is required to resolve it; do not suggest solutions — findings are findings, not redesigns

**If `RETURNED`:** the contract returns to Task 2.3 with the findings list attached. Task 2.3 addresses each finding. Task 2.4 runs again. This loops until `ACCEPTED`.

**Done when:** `review_status: ACCEPTED`, `reviewed_by` is set, acceptance timestamp is recorded, verifier identity is different from the drafter

***

## Items to Flag for Higher-Level Consideration

**F6 — The Verifiability Standard**
The rule that every contract claim must have a paired, executable verification method is not unique to Step 2. Any step that produces a document with factual claims about a system state will need the same standard. This belongs at framework level as a named principle.

**F7 — The Producer/Verifier Separation Invariant**
DoD 7 formalises what the principles call T5 — no actor judges their own work. But it needs a structural enforcement mechanism: the system must make it impossible for the same party that produced an output to set it to `ACCEPTED`. This is a framework-level invariant, not a step-level policy.

**F8 — Carry-Forward of Open Questions Between Steps**
Step 2 explicitly reclassifies `open_questions` from Step 1 in the context of Step 2's requirements. This pattern — each step inherits the prior step's unresolved questions and reclassifies them against its own requirements — is structural. It needs a defined protocol for how open questions travel between steps, and how their classification can change.

**F9 — Version Ambiguity Protocol**
The treatment of undeclared versions — not assumed, not left empty, documented as open questions that block the contract — is a specific decision that applies wherever versions appear. Steps 3 and 4 will encounter the same challenge (agent template versions, pattern schema versions). Define once.