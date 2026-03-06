A good bootstrapping zone model needs to be simple, fully covered by existing docs, and focused on “from nothing to first task executed”. Here’s a workable model tuned for experiments.

***

## High-Level Zone Model (for Bootstrapping)

Use five zones plus Zone 0, but scope them narrowly to software delivery:

| Zone | Name | Purpose in bootstrapping |
|---|---|---|
| 0 | Framework Evolution | Design and create agents, tools, schemas, policies |
| 1 | Idea & Feature Framing | Capture and shape “what are we building?” at feature level |
| 2 | Definition (AC + UI) | Turn feature into clear AC + UI brief |
| 3 | Task Prep & Context | Decompose into tasks, tests, environment, context packages |
| 4 | Execution & Proof | Implement tasks, produce proofs, QA |
| 5 | Delivery & CICD | Integrate, deploy, and confirm in staging/production |

This is basically your existing 1–5 zones, but we constrain their *scope* to what’s needed to bootstrap and run experiments.

***

## Zone Purposes (Bootstrapping-Scoped)

### Zone 0 — Framework Evolution

- Scope:
  - Agent Creation Policy flow (FOA, Agent Spec QA, Agent Template Creator).
  - Base Agent Template and skills.
  - Tool Grammar, audit schema, DB schema, context tree.
- Work you actually do here now:
  - Define/iterate `TaskPerformerAgent`, `QAExecutor`, `ContextAgent`, `CICDAgent`, Zonal Advisors using the Zone 0 flow in `agent-creation-policy-v0.1.md`. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/eea923f7-9392-4734-ae39-4710d79ba622/experiment-2-will-need-to-wait-0U5RBKbfTZ6BlRtDT_4fYw.md)
  - Maintain `context-tree.md` and naming conventions.
- Entry:
  - Gap signals: “UnknownTaskTypeEncountered”, or you manually decide “we need a CICDAgent”.
- Exit:
  - `AgentClassCreated` event, template added to roster, pattern library entry written. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/4a0d12d2-3c1d-4326-90e4-00abc505afd0/ONE-Ontology.md)

This zone is already well-specified; you can use it as-is.

***

### Zone 1 — Idea & Feature Framing

For bootstrapping, keep this extremely lightweight.

- Scope:
  - Capture ideas.
  - Write a minimal feature spec and success criteria.
- Actors:
  - Human Framework Owner (you).
  - Optional: FeatureOwnerAgent later, but not needed for early experiments.
- Artefacts:
  - `idea-*.md`
  - `feature-spec.md`
  - `feature-success-criteria.md`
- Entry:
  - You decide “I want Nexus to do X (e.g. implement TaskPerformer automatically).”
- Exit gate:
  - FO decides: “There is a single clear feature we want to prototype next.”
  - No automation needed yet; manual is fine.

For bootstrapping, this zone is just: “write the feature spec and success criteria by hand”.

***

### Zone 2 — Definition (AC + UI)

Use what you already have in the Uncertainty Analysis and Context Curation pattern. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/2844a831-359e-4c78-8899-f2166d0b2fcf/zone-uncertainty-analysis.md)

- Scope:
  - Turn a feature into:
    - A full set of acceptance criteria.
    - (Optionally) a UI artefact (if the feature has UI).
- Actors:
  - Feature Owner (you or FeatureOwnerAgent later).
  - QA Agent Definition (for reviewing AC, UI briefs).
  - Zone 2 Advisor (for AC/UI ambiguities; you have the model in `zone-uncertainty-analysis.md`). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/2844a831-359e-4c78-8899-f2166d0b2fcf/zone-uncertainty-analysis.md)
- Artefacts:
  - `feature-ac.md` (Given/When/Then style).
  - `ui-artefact.md` or `ui-brief.md` (if relevant).
- Entry:
  - Zone 1 feature spec exists.
- Exit gate (ready for bootstrapping):
  - AC written and reviewed (QA Definition).
  - For now, you can skip full UI if your bootstrapping feature is backend-only.

For early experiments, you can do Zone 2 mostly by hand plus using your AC patterns; the important part is that each feature has verifiable AC before Zone 3.

***

### Zone 3 — Task Preparation & Context

This is your main workhorse zone for bootstrapping, and it’s already well-analyzed. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)

- Scope:
  - Decompose features into tasks.
  - Define task-level AC and tests.
  - Curate and approve context packages.
- Actors:
  - TaskOwnerAgent (or you initially).
  - TestOwnerAgent (writes tests).
  - ContextAgent (curates context packages). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)
  - QA Agent Definition (reviews task specs, tests, context package).
  - Zone 3 Advisor Agent (handles ambiguity about AC, tests, context, decomposition). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/2844a831-359e-4c78-8899-f2166d0b2fcf/zone-uncertainty-analysis.md)
- Artefacts:
  - `task-spec.md`
  - `task-ac.md`
  - `task-tests.md`
  - `context-package.md` (curated, APPROVED before Zone 4). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)
  - `environment-contract-template.md`
- Entry:
  - Zone 2 feature with AC in place.
- Exit gate for bootstrapping:
  - At least one task in `PUBLISHED` or `READY_FOR_EXECUTION` state with:
    - Approved `task-spec`, `task-ac`, `task-tests`.
    - Approved `context-package`.
    - Environment contract template defined.
  - FO approval on publishing (irreversible commitment) as per Context Curation pattern. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)

For experiments, you can:
- Pick *one* task that encapsulates “build TaskPerformerAgent template”.
- Run it through a lean Zone 3:
  - Write `task-spec`, `task-ac`, `task-tests`.
  - Have ContextAgent curate `context-package` using patterns from your docs.
  - Approve manually via FO + QA Definition.

***

### Zone 4 — Execution & Proof

This is where your existing pre-flight, uncertainty, and TaskPerformer spec already live. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/85229eca-47a0-4539-831e-7d6f37d94b1c/preflight-check-protocol.md)

- Scope:
  - Execute tasks.
  - Call preflight, handoff-repeatback, raise-uncertainty.
  - Produce proofs, then hand to QA.
- Actors:
  - TaskPerformerAgent (Zone 4 EXECUTOR). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/a6a2f57d-a307-4942-8d29-09849c6f2944/example-spec-preflight-check.md)
  - QA Agent Execution (Zone 4 verifier).
  - Zone 4 Advisor Agent (for execution-time uncertainties). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/2844a831-359e-4c78-8899-f2166d0b2fcf/zone-uncertainty-analysis.md)
- Mandatory behaviour:
  - Preflight:
    - `preflightcheck` before any work. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/85229eca-47a0-4539-831e-7d6f37d94b1c/preflight-check-protocol.md)
    - CLEAR / ASSUMED / BLOCKED → must obey.
  - Handoff repeat-back on entering Zone 4:
    - `handoffrepeatback` to confirm understanding. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/a6a2f57d-a307-4942-8d29-09849c6f2944/example-spec-preflight-check.md)
  - Uncertainty:
    - On BLOCKED preflight or QA misunderstanding, call `agentraiseuncertainty` and stop. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/85229eca-47a0-4539-831e-7d6f37d94b1c/preflight-check-protocol.md)
- Artefacts:
  - `proof-of-completion.md`
  - `uncertainty-log.md`
  - `handoff-repeatback.md`
- Entry:
  - `TaskPublished` in Zone 3, context package approved, environment contract snapshot taken at claim time. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/627df371-76c7-43de-bc39-f7e6206d3347/context-curation-pattern.md)
- Exit gate:
  - `submitproof` + QA Execution pass → `QA_PASSED`.
  - FO approval → `APPROVED` (or similar).

For bootstrapping, **Zone 4 is where you prove the framework can execute its own “create TaskPerformer” task**:
- Use the example TaskPerformer spec. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/a6a2f57d-a307-4942-8d29-09849c6f2944/example-spec-preflight-check.md)
- Implement preflight, handoff, uncertainty tools. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/85229eca-47a0-4539-831e-7d6f37d94b1c/preflight-check-protocol.md)
- Run one task end-to-end.

***

### Zone 5 — Delivery & CICD

You already resolved H13 by bringing CICD into the domain and defining the CICD Agent and Zone 5 policies. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/eea923f7-9392-4734-ae39-4710d79ba622/experiment-2-will-need-to-wait-0U5RBKbfTZ6BlRtDT_4fYw.md)

- Scope:
  - Integrate code.
  - Run integration tests.
  - Deploy to staging / production.
  - Capture deployment record.
- Actors:
  - CICDAgent (Zone 5 EXECUTOR).
  - Feature Owner Agent (review user testing, delivery).
  - Zone 5 Advisor Agent (for delivery uncertainties). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/eea923f7-9392-4734-ae39-4710d79ba622/experiment-2-will-need-to-wait-0U5RBKbfTZ6BlRtDT_4fYw.md)
  - FO (for AWAITING_FO escalations).
- Artefacts:
  - `deployment-record.md` (Zone 5 proof-of-completion). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/eea923f7-9392-4734-ae39-4710d79ba622/experiment-2-will-need-to-wait-0U5RBKbfTZ6BlRtDT_4fYw.md)
  - Integration test logs.
  - User testing artefacts (for later).
- Entry:
  - Feature has all tasks APPROVED / DONE.
- Exit gate:
  - Staging verified, integration tests pass.
  - FO approves promotion.
  - `deployment-record.md` passes QA; feature state → `DELIVERED` or `DONE`.

For bootstrapping:
- Keep Zone 5 minimal:
  - Use CICDAgent only to manage *this repository’s* branch, PR, and merge for the Nexus MCP server itself.
  - Don’t tackle user testing yet — just integration tests + staging verification.

***

## How to Use This Zone Model for Bootstrapping

For the specific goal “bootstrap a software project using Nexus”, here’s how this model guides you:

1. **Stay in Zone 0 until you have:**
   - Minimal agent roster: FOA, Agent Spec QA, TaskPerformer, QA Execution, ContextAgent, CICDAgent.
   - Preflight, uncertainty, handoff tools implemented (specs are done already). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/a6a2f57d-a307-4942-8d29-09849c6f2944/example-spec-preflight-check.md)

2. **Use Zones 1–3 only lightly:**
   - Zone 1: you manually define the initial features (“Create TaskPerformer agent template”, “Create QA Execution agent template”, etc.).
   - Zone 2: write AC directly (short, Given–When–Then).
   - Zone 3: for each feature, define a single task that represents the core work and curate its context package using ContextAgent.

3. **Focus experiments around Zones 3–4:**
   - The *first* experiment is: can TaskPerformer + QA Execution agents, running under preflight + uncertainty + context curation, successfully create and prove their own templates for these tasks?
   - That is the smallest “vertical slice” through 0–4 that tests everything important.

4. **Bring in Zone 5 only when:**
   - You want to test end-to-end from “task spec” to “code merged and deployed” in this repo.
   - Start with a trivial deployment (e.g., deploy a small CLI or a non-critical service) so you can focus on CICDAgent behaviour and uncertainties.

***

## Why This Model Is Good Enough For Now

- It reuses your existing zone semantics and uncertainty/context work. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_168390a0-2fa2-46bc-b85d-bb5896b959b2/eea923f7-9392-4734-ae39-4710d79ba622/experiment-2-will-need-to-wait-0U5RBKbfTZ6BlRtDT_4fYw.md)
- It narrows each zone’s **bootstrapping responsibilities** so you don’t have to finish the full product lifecycle before experimenting.
- It respects the new foundation principles:
  - P2/P3: Zone 0 structurally governs agents and tools.
  - T1–T5: Definition, proof, verification, and audit are explicit in Zones 3–4.
  - PF2/PF3: You can add a lightweight prototype/validation step inside Zone 3 later without changing the structure.
- It gives you a clean place to plug in further work (Discovery, multiple ideation agents, etc.) once the bootstrapping loop is proven.

If you’d like, the next concrete step can be: define the exact state machine for Zones 3–4 using this model (just the states and transitions needed for the first bootstrapping task), so you have something precise to implement.