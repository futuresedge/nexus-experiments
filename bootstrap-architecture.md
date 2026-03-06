# Zone 0 Deep Dive: Bootstrap Architecture

***

## 1. The Toolkit — What You Start With

The toolkit is the project-agnostic foundation that exists *before* any project begins. It is cloned/installed once and never modified by project work.

```
toolkit/
│
├── .framework/                        ← framework documents (read-only)
│   ├── foundation-principles.md
│   ├── policies/
│   │   ├── work-topology.md
│   │   ├── lifecycle-architecture.md
│   │   ├── tool-grammar.md
│   │   ├── agent-design-standards.md
│   │   └── agent-creation-policy.md
│   ├── agent-classes/
│   │   ├── agent-roster.md
│   │   ├── base-agent-template.md
│   │   └── [class definitions — one per agent class]
│   └── templates/
│       ├── project-manifest.template.md
│       ├── environment-contract.template.md
│       └── context-card.template.md
│
├── .github/
│   ├── agents/
│   │   └── [base .agent.md files — one per class in roster]
│   ├── copilot-instructions.md        ← base instructions, project-agnostic
│   └── instructions/
│       └── [base .instructions.md files]
│
├── .skills/                           ← skill files loaded by agents
│   ├── compression.skill.md
│   ├── uncertainty-classification.skill.md
│   ├── proof-template-writing.skill.md
│   ├── agent-spec-writing.skill.md
│   ├── pattern-evaluation.skill.md
│   ├── environment-contract-writing.skill.md
│   └── context-card-validation.skill.md
│
└── nexus-server/                      ← MCP server
    ├── src/
    │   ├── tools/
    │   │   ├── universal/             ← always registered
    │   │   │   ├── get_context_card
    │   │   │   ├── raise_uncertainty
    │   │   │   ├── search_knowledge_base
    │   │   │   ├── get_my_capabilities
    │   │   │   └── get_current_state
    │   │   ├── framework/             ← Zone 0 tools
    │   │   │   ├── write_pattern
    │   │   │   ├── read_patterns
    │   │   │   ├── write_agent_template
    │   │   │   ├── submit_spec_test_results
    │   │   │   └── write_project_manifest
    │   │   └── lifecycle/             ← delivery tools
    │   │       └── [all tools from transition table]
    │   ├── policy-engine/
    │   ├── audit-log/
    │   └── observable-stream/
    ├── schema.sql                     ← SQLite schema
    └── package.json
```

**What the toolkit does NOT contain:**
- Any project-specific configuration
- Any patterns (Pattern Library is empty until seeded)
- Any project manifest or environment contract
- Any task or feature data

***

## 2. Input Data Needed

Zone 0 cannot begin without these inputs from `human:director`. These are the raw materials — before any agent touches them.

**Required (hard blockers):**

| Input | Format | AstroJS Example |
|---|---|---|
| Project name | String | `petes-plumbing-site` |
| Project description | 2–4 sentences | "Marketing website for Pete's Plumbing, a local Melbourne business. Needs service pages, contact form, and Google Maps embed. SEO is a priority." |
| Tech stack declaration | Named technologies + versions where known | AstroJS 5.x, Tailwind CSS 4, Netlify deployment, no backend, no database |
| Deployment target | Environment description | Netlify, custom domain `petesplumbing.com.au`, branch deploy previews for staging |
| Development environment | Local setup | Node 22, pnpm, macOS, VS Code |
| Human actors | Names + roles | `human:director` = Pete; `human:approver` = Pete (same person for this project) |
| Appetite declaration | Rough size signal | "Small — a few days of agent work, not weeks" |

**Optional (enrich output quality, not hard blockers):**

| Input | AstroJS Example |
|---|---|
| Known constraints | "No React. Keep bundle size minimal. Must score 90+ on Lighthouse." |
| Existing assets | Logo files, brand colours, copy drafts |
| Reference sites | "Something like [example]" |
| Integration requirements | "Contact form submits to Netlify Forms, no third-party form service" |
| Out of scope | "No CMS, no blog, no e-commerce" |

***

## 3. Zone 0 Task Sequence

Zone 0 has five tasks in dependency order. Each is a complete unit of work with a named executor and reviewer. No task begins until the previous gate is passed.

***

### Task Z0-1 — Project Registration

**Question:** What is this project, and is the input data complete enough to proceed?

**Input:** Human:director's raw brief (above)
**Output:** `project-manifest.md` — structured, machine-readable project record

```markdown
# project-manifest.md (schema)
  project_id
  project_name
  description
  human_actors            [{ name, role }]
  appetite
  out_of_scope_declaration
  open_questions          [any inputs that were unclear or missing]
  status                  DRAFT | APPROVED
```

**Executor:** `ProjectRegistrar` *(new agent — see §5)*
Translates the human brief into a structured manifest. Raises uncertainty if any required input is ambiguous or missing. Does not invent inputs.

**Reviewer:** `human:director`
Reviews manifest for fidelity. The manifest is a restatement of what they said — if it's wrong, the error is in the translation, not the intent. Approves or returns with corrections.

**Gate:** `human:director` approves manifest before Z0-2 begins.

**AstroJS example output:**
```
project_id:    petes-plumbing-site
appetite:      small (< 5 delivery tasks estimated)
out_of_scope:  CMS, blog, e-commerce, backend services, React
open_questions: []
status:        APPROVED
```

***

### Task Z0-2 — Environment Contract

**Question:** What does the system need to be true about the environment for work to succeed?

**Input:** `project-manifest.md` (tech stack declaration)
**Output:** `environment-contract.md` — the canonical reference for all environment-dependent decisions in the project

```markdown
# environment-contract.md (schema)
  runtime           { name, version, package_manager }
  framework         { name, version, config_file }
  styling           { name, version }
  deployment        { provider, target_url, staging_url, deploy_trigger }
  dev_environment   { os, editor, port, start_command, build_command }
  services          [{ name, type, local_mock? }]
  constraints       [list of named technical constraints]
  verification      { how_to_check_local, how_to_check_deployed }
```

**Executor:** `EnvironmentContractAuthor` *(new agent — see §5)*
Writes the contract from the manifest's tech stack declaration. Uses its skill file to know what fields are required for each type of stack. For AstroJS/Netlify, knows to ask about: `astro.config.mjs`, output mode (`static` vs `server`), Netlify adapter, environment variables.

**Reviewer:** `EnvironmentReviewer`
This is the first activation of EnvironmentReviewer — in review mode (not post-deploy mode). Checks the contract for completeness and internal consistency. Does the `verification` section actually describe how to check the things declared? Are all constraints testable?

**Gate:** EnvironmentReviewer returns PASS before Z0-3 begins.

**AstroJS example — key fields:**
```
runtime:       Node 22, pnpm
framework:     AstroJS 5.x, static output, astro.config.mjs
deployment:    Netlify, petesplumbing.com.au,
               staging: deploy-preview--petes.netlify.app
build_command: pnpm build
constraints:   [no-react, lighthouse-90, no-external-form-service]
verification:  local: pnpm build && pnpm preview
               deployed: Netlify deploy log + Lighthouse CI check
```

***

### Task Z0-3 — Agent File Generation

**Question:** Do all required agent class files exist, correctly configured for this project?

**Input:** `project-manifest.md`, `environment-contract.md`, base agent templates from toolkit
**Output:** `.github/agents/*.agent.md` — one project-specific agent file per class in MVP roster

This task is a loop: for each agent class in the MVP roster, generate a project-specific agent file from the base template. Project-specific means: file paths reference this project's directory structure, tech-stack-relevant skills are loaded, and `CONTEXTTREEREF` entries are valid for this project's context tree.

For the AstroJS example, `TaskPerformer` gets AstroJS-specific skill references. `EnvironmentContractAuthor` gets an `environment-contract-writing.skill.md` that knows about static site generators.

**Executor:** `TemplateAuthor`
Reads the base agent template for each class, reads the project manifest and environment contract, and produces a project-specific `.agent.md` file. Does not invent capabilities — only instantiates the template with project-specific values.

**Reviewer:** `AgentSpecReviewer`
Runs the spec test suite against each generated agent file. The same spec tests used in the Zone 0 agent creation process apply here. Any file that fails spec tests is returned to TemplateAuthor with findings.

**Gate:** All MVP agent files pass AgentSpecReviewer spec tests. FrameworkOwner reviews the complete set for context tree consistency (no overlaps, no gaps).

**MVP agent files to generate (16 files):**
```
FrameworkOwner.agent.md
FeatureOwner.agent.md
TaskOwner.agent.md
UncertaintyOwner.agent.md
TaskOrchestrator.agent.md
QAOrchestrator.agent.md
DeliveryOrchestrator.agent.md
ContextCurator.agent.md
ProofDesigner.agent.md
TaskPerformer.agent.md
Deployer.agent.md
TemplateAuthor.agent.md
AgentSpecReviewer.agent.md
ProofReviewer.agent.md
ACReviewer.agent.md
EnvironmentReviewer.agent.md
```
*(SpecValidator deferred — optional MVP)*

***

### Task Z0-4 — Pattern Library Seeding

**Question:** Does the Pattern Library contain enough known-good patterns to give agents useful starting context for the first real task?

**Input:** `environment-contract.md`, `project-manifest.md`, external knowledge of the declared tech stack
**Output:** Pattern Library with ≥ 5 verified patterns relevant to this project

Pattern Library entries are not invented — they are documented from existing knowledge of the tech stack. Each entry has the same structure as any pattern: a problem it solves, the approach, evidence of effectiveness, and applicability conditions.

**Executor:** `PatternSeeder` *(new agent — see §5)*
Searches its skill file knowledge base and the tech stack declaration to identify patterns worth seeding. For AstroJS, this includes things like: component structure conventions, content collection patterns, Tailwind utility patterns, Netlify build configuration patterns, Lighthouse optimisation patterns.

**Reviewer:** `FrameworkOwner`
Reviews each seeded pattern for: clarity, applicability conditions (not too broad), evidence plausibility (is there a basis for claiming this works?), and format conformance. Rejects patterns that are too vague ("write good code") or too narrow ("only applies to this one task").

**Gate:** ≥ 5 patterns promoted to `PROVISIONAL` status by FrameworkOwner.

**AstroJS example — initial pattern seeds:**

| Pattern | Problem it solves |
|---|---|
| `astro-component-colocation` | Where to put components relative to pages |
| `tailwind-utility-scoping` | Avoiding class name collisions in Astro components |
| `netlify-static-output-config` | Correct `output: static` config for Netlify adapter |
| `astro-image-optimisation` | Using `<Image>` component for Lighthouse score |
| `astro-contact-form-netlify` | Netlify Forms integration without backend |
| `proof-by-build-success` | Using `pnpm build` output as primary proof evidence for Astro tasks |

The last pattern (`proof-by-build-success`) is meta — it tells ProofDesigner how to write proof templates for this stack. This is the most valuable pattern to seed early.

***

### Task Z0-5 — Bootstrap Validation

**Question:** Is the framework actually operational for this project, end to end?

**Input:** All Zone 0 outputs (manifest, environment contract, agent files, pattern library)
**Output:** `bootstrap-report.md` — certification that Zone 0 is complete, with gap list if any

This is not a rubber stamp. `BootstrapValidator` runs through a structured checklist and actively tests that the system is operational, not just that files exist.

**Executor:** `BootstrapValidator` *(new agent — see §5)*
Runs the bootstrap validation checklist (see §4 below). Attempts a smoke test: creates a minimal `DRAFT` task, verifies the Policy Engine responds correctly, verifies `ContextCurator` can generate a context card, verifies the audit log writes the entry. Does not proceed to `IN_PROGRESS` — the smoke test stops at `CONTEXT_READY`.

**Reviewer:** `human:director`
Reviews the bootstrap report. Approves bootstrap completion or returns with gaps to address. This is the only human gate in Zone 0 besides Z0-1.

**Gate:** `human:director` approves bootstrap report. Cycle `BOOTSTRAP` transitions to `CLOSED`.

***

## 4. What Does Done Look Like for Zone 0?

Done is a structured checklist, not a feeling. `BootstrapValidator` verifies each item and produces pass/fail evidence for each.

```
BOOTSTRAP COMPLETION CHECKLIST

Documents:
  ✅ project-manifest.md exists, is APPROVED by human:director
  ✅ environment-contract.md exists, passed EnvironmentReviewer review
  ✅ All 16 MVP agent .agent.md files exist
  ✅ All 16 agent files pass AgentSpecReviewer spec tests
  ✅ Pattern Library contains ≥ 5 PROVISIONAL patterns
  ✅ bootstrap-report.md exists

Infrastructure:
  ✅ Nexus MCP server is running and responding to tool calls
  ✅ SQLite audit log is operational (test entry written and read back)
  ✅ Observable stream is operational (test event emitted and visible)
  ✅ Policy Engine responds to a state transition test
  ✅ get_context_card returns a valid card for at least one agent class

Smoke test:
  ✅ A test task was created (create_task smoke-01)
  ✅ A test task spec was written (write_task_spec smoke-01)
  ✅ A test proof template was written by a different agent
       (PE-01 verified: ProofDesigner ≠ TaskPerformer in audit log)
  ✅ submit_task_spec transitions task to SPEC_APPROVED
  ✅ ContextCurator generates 6 context cards for smoke-01
  ✅ submit_context_ready transitions task to CONTEXT_READY
  ✅ Smoke test task cancelled (cancel_task smoke-01)
  ✅ Cancellation audit entry exists

Human sign-off:
  ✅ human:director approves bootstrap-report.md
```

**Zone 0 is NOT done if any of the following are true:**
- A required agent file is missing or fails spec tests
- The smoke test task does not reach `CONTEXT_READY`
- The audit log has gaps (a tool call with no audit entry)
- The Pattern Library has fewer than 5 PROVISIONAL patterns
- `human:director` has not explicitly approved the bootstrap report

***

## 5. New Agent Classes Needed for Zone 0

Walking the task sequence reveals four agent classes not previously in the roster:

***

### `ProjectRegistrar`
**Type:** EXECUTOR
**Zone:** 0
**Job:** Translates a human:director project brief into a structured, machine-readable project manifest.
**READS:** project brief (human input, freeform), `project-manifest.template.md`
**WRITES:** `project-manifest.md`
**NEVER:** environment contract, agent files, pattern library
**Key skill:** `project-registration.skill.md` — knows what fields are required, how to identify missing inputs, how to raise uncertainty for ambiguous inputs without inventing values
**Reviewer:** `human:director` (not an agent — this is a Tier 4 gate by nature: the human reviews their own intent, restated)

***

### `EnvironmentContractAuthor`
**Type:** EXECUTOR
**Zone:** 0
**Job:** Writes a complete, verifiable environment contract from a project manifest's tech stack declaration.
**READS:** `project-manifest.md`, `environment-contract.template.md`
**WRITES:** `environment-contract.md`
**NEVER:** project manifest, agent files, pattern library
**Key skill:** `environment-contract-writing.skill.md` — knows required fields per tech stack type (static site, API, full-stack, etc.), knows what "verifiable" means per field
**Reviewer:** `EnvironmentReviewer` (already in roster — this is the first of its two activation contexts)

***

### `PatternSeeder`
**Type:** EXECUTOR
**Zone:** 0
**Job:** Produces initial Pattern Library entries for a declared tech stack, drawing on tech stack knowledge and the pattern schema.
**READS:** `environment-contract.md`, `project-manifest.md`, pattern library schema
**WRITES:** pattern library entries (CANDIDATE status)
**NEVER:** project manifest, environment contract, agent files
**Key skill:** `pattern-seeding.skill.md` — knows the pattern schema, knows how to identify genuinely reusable patterns vs project-specific one-offs, knows the evidence threshold for PROVISIONAL promotion
**Reviewer:** `FrameworkOwner` (promotes candidates to PROVISIONAL)

***

### `BootstrapValidator`
**Type:** REVIEWER
**Zone:** 0
**Job:** Verifies that Zone 0 is complete and the framework is operational for this project, against the bootstrap completion checklist.
**READS:** All Zone 0 outputs (manifest, contract, all agent files, pattern library entries), bootstrap checklist
**WRITES:** `bootstrap-report.md`
**NEVER:** any Zone 0 output document (reviewer — reads only)
**Key skill:** `bootstrap-validation.skill.md` — knows how to run the smoke test, knows the completion checklist, knows how to distinguish "file exists" from "file is functional"
**Reviewer:** `human:director`

***

## Updated Zone 0 Agent Roster

| Agent Class | Type | Job in Zone 0 |
|---|---|---|
| `FrameworkOwner` | OWNER | Orchestrates Zone 0, approves agent files, promotes patterns, closes bootstrap |
| `ProjectRegistrar` | EXECUTOR | Translates project brief → project manifest |
| `EnvironmentContractAuthor` | EXECUTOR | Writes environment contract from tech stack |
| `TemplateAuthor` | EXECUTOR | Generates project agent files from base templates |
| `PatternSeeder` | EXECUTOR | Seeds Pattern Library for declared tech stack |
| `BootstrapValidator` | REVIEWER | Certifies Zone 0 complete via checklist + smoke test |
| `AgentSpecReviewer` | REVIEWER | Runs spec tests against generated agent files |
| `EnvironmentReviewer` | REVIEWER | Verifies environment contract completeness |

`UncertaintyOwner` is also active cross-cuttingly across all Zone 0 tasks.

***

**The thing this surfaces most clearly:** Zone 0 is not a setup script — it is a full application of the framework's own principles to the act of configuring the framework. Every task has an executor and a reviewer. Every output has a proof condition. The human gate appears exactly twice: once to confirm intent (Z0-1) and once to confirm the system is ready (Z0-5). Everything in between is agent work.

This also resolves the chicken-and-egg problem: the toolkit's Zone 0 agents (`ProjectRegistrar`, `EnvironmentContractAuthor`, `TemplateAuthor`, `PatternSeeder`, `BootstrapValidator`) are the bootstrapping exception — they are hand-built once in the toolkit and never need to be created by the Zone 0 process. They are the Zone 0 process.