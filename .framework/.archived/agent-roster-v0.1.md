# Agent Roster

**Version:** 0.1
**Status:** Active — evolving
**Dependencies:**
  Foundation Principles v2.0
  Agent Design Standards v1.0
  Lifecycle Architecture v1.0
  Work Topology v1.0
**Last Updated:** 2026-03-05

---

## Purpose

This document is the authoritative list of all agent classes in the
Nexus Framework. It records what each agent class is responsible for,
which track and phase it operates in, its type, and its MVP status.

This is a living document. Agent classes are added when the lifecycle
or a framework experiment surfaces a need, and formalised through the
Zone 0 agent creation process. Every entry here either has or needs a
corresponding agent class definition in `.framework/agent-classes/`.

---

## Summary Table

| Agent Class | Type | user-invokable | Track / Phase | MVP | Status |
|---|---|---|---|---|---|
| **OWNERS** | | | | | |
| `FrameworkOwner` | OWNER | ✅ | Zone 0 / Learning Layer | ✅ | Defined |
| `FeatureOwner` | OWNER | ✅ | Discovery → Shaping | ✅ | Defined |
| `TaskOwner` | OWNER | ✅ | Delivery → Specification | ✅ | Defined |
| `UncertaintyOwner` | OWNER | ✅ | Cross-cutting | ✅ | Defined |
| **ORCHESTRATORS** | | | | | |
| `TaskOrchestrator` | ORCHESTRATOR | ✅ | Delivery → Execution | ✅ | Needs class definition |
| `QAOrchestrator` | ORCHESTRATOR | ✅ | Delivery → Execution (QA) | ✅ | Needs class definition |
| `DeliveryOrchestrator` | ORCHESTRATOR | ✅ | Delivery → Release | ✅ | Needs class definition |
| **EXECUTORS** | | | | | |
| `ContextCurator` | EXECUTOR | ❌ | Delivery → Specification | ✅ | Needs class definition |
| `ProofDesigner` | EXECUTOR | ❌ | Delivery → Specification | ✅ | Needs class definition |
| `TaskPerformer` | EXECUTOR | ❌ | Delivery → Execution | ✅ | Needs class definition |
| `Deployer` | EXECUTOR | ❌ | Delivery → Release | ✅ | Needs class definition |
| `TemplateAuthor` | EXECUTOR | ❌ | Zone 0 | ✅ | Needs class definition |
| `SpecValidator` | EXECUTOR | ❌ | Delivery → Specification | 🟡 | Needs class definition |
| **REVIEWERS** | | | | | |
| `ProofReviewer` | REVIEWER | ❌ | Delivery → Execution (QA) | ✅ | Needs class definition |
| `ACReviewer` | REVIEWER | ❌ | Delivery → Execution (QA) | ✅ | Needs class definition |
| `EnvironmentReviewer` | REVIEWER | ❌ | Delivery → Execution + Release | ✅ | Needs class definition |
| `AgentSpecReviewer` | REVIEWER | ❌ | Zone 0 | ✅ | Needs class definition |
| **DEFERRED — Discovery Track** | | | | | |
| `ProblemResearcher` | EXECUTOR | ❌ | Discovery → Problem | ❌ | Not yet designed |
| `PersonaEmpathiser` | EXECUTOR | ❌ | Discovery → Problem | ❌ | Not yet designed |
| `ResearchSynthesiser` | REVIEWER | ❌ | Discovery → Problem | ❌ | Not yet designed |
| Ideation cluster (×6) | EXECUTOR | ❌ | Discovery → Shaping | ❌ | Not yet designed |
| `IdeaSynthesiser` | EXECUTOR | ❌ | Discovery → Shaping | ❌ | Not yet designed |
| `IdeaPrioritiser` | EXECUTOR | ❌ | Discovery → Shaping | ❌ | Not yet designed |
| `Prototyper` | EXECUTOR | ❌ | Discovery → Shaping | ❌ | Not yet designed |
| `UserValidator` | REVIEWER | ❌ | Discovery → Shaping | ❌ | Not yet designed |
| **DEFERRED — Operations Track** | | | | | |
| `SystemMonitor` | EXECUTOR | ❌ | Operations → Monitor | ❌ | Not yet designed |
| `FindingTriager` | EXECUTOR | ❌ | Operations → Optimise | ❌ | Not yet designed |

**MVP key:**
✅ Required for MVP delivery path
🟡 Optional for MVP — useful but not blocking
❌ Not in MVP scope

---

## Design Note — QAOrchestrator Naming

In earlier framework documents this agent was called `QAExecutor`.
The rename to `QAOrchestrator` is required by the Agent Design Standards
spec test T03: an agent that holds the `agent` tool and delegates to
subagents (ProofReviewer, ACReviewer, EnvironmentReviewer) must be of
type ORCHESTRATOR. Orchestrator agents must end in `Orchestrator` and
must have `user-invokable: true`.

`QAOrchestrator` is not user-invokable in practice — it is activated
by the Policy Engine on `SUBMITTED` state. However, `user-invokable: true`
means it *can* be invoked directly if needed (e.g., to re-run QA on a
task that was returned from AWAITING_APPROVAL with questions). The
capability is held; the normal activation path is automated.

All prior references to `QAExecutor` in framework documents are
superseded by `QAOrchestrator`.

---

## Agent Class Entries

---

### FrameworkOwner

**Type:** OWNER
**user-invokable:** true
**Track / Phase:** Zone 0, Learning Layer (all tracks)
**MVP:** ✅

**Responsibility:**
Owns the health and evolution of the framework. Governs the Zone 0
agent creation process, maintains the Pattern Library, aggregates
cycle retros, approves new agent classes (NV ≤ 1), and escalates
novel decisions to human:director.

**Gate authority:**
- Approves new agent class definitions (NV ≤ 1)
- Approves pattern promotions and retirements
- Approves framework policy changes
- Cancels tasks (any state)
- Closes delivery cycles (COMPLETE → RETRO_IN_PROGRESS → CLOSED)

**Delegates to:**
`TemplateAuthor`, `AgentSpecReviewer`, `ContextCurator` (for pattern
library maintenance)

**Key tools (sketch):**
```
Universal (all 4)
write_pattern, read_patterns
cancel_task_{task_id}
submit_cycle_retro_{cycle_id}
create_cycle, close_cycle
agent (delegates to subagents)
```

**Certainty threshold:** 0.85
(Lower than reviewers — FrameworkOwner makes judgment calls; high
certainty would cause excessive escalation)

**Open questions:** None — this agent class is well-defined from
earlier sessions and the Agent Creation Policy document.

---

### FeatureOwner

**Type:** OWNER
**user-invokable:** true
**Track / Phase:** Discovery → Shaping output; Pitch lifecycle
**MVP:** ✅

**Responsibility:**
Writes feature specifications and acceptance criteria for shaped pitches.
Holds gate authority over feature-level definitions. A shaped pitch does
not exist without FeatureOwner having written and approved its feature
spec and AC.

**Gate authority:**
- Writes and owns feature spec and AC
- Approves feature spec as ready for TaskOwner decomposition
- May reject a TaskOwner decomposition that misrepresents the feature spec
- Commits pitches (with human:director)

**Key tools (sketch):**
```
Universal (all 4)
write_feature_spec, read_feature_spec
write_ac, submit_ac
request_ac_approval
read_task_spec_{task_id}  (read-only — to verify decomposition fidelity)
```

**Certainty threshold:** 0.80

**Open questions:**
- In the Discovery track (post-MVP), FeatureOwner may be fed directly
  by the Shaping phase output. In the MVP, it is human:director who
  provides the shaped pitch and FeatureOwner translates it into
  a formal spec and AC. This handoff needs clarification when the
  Discovery track is designed.

---

### TaskOwner

**Type:** OWNER
**user-invokable:** true
**Track / Phase:** Delivery → Specification
**MVP:** ✅

**Responsibility:**
Decomposes an approved feature spec into independently completable tasks.
Writes task specifications. Owns the task decomposition document.
Assigns QA tier to each task. Approves tasks as ready for ProofDesigner.

**Gate authority:**
- Writes task specs
- Sets QA tier on each task (proposed, then validated by SpecValidator
  if available)
- Submits task spec for approval (`DRAFT` → `SPEC_APPROVED` gate)
- Cannot write proof templates (structural — held by ProofDesigner only)

**Key tools (sketch):**
```
Universal (all 4)
write_task_spec_{task_id}
submit_task_spec_{task_id}
create_task_{task_id}
read_feature_spec
read_ac
write_decomposition, read_decomposition
```

**Certainty threshold:** 0.80

**Open questions:**
- Does TaskOwner or FrameworkOwner resolve conflicts when a task
  decomposition is contested? Proposed: TaskOwner owns decomposition;
  FrameworkOwner arbitrates structural disputes.

---

### UncertaintyOwner

**Type:** OWNER
**user-invokable:** true
**Track / Phase:** Cross-cutting — all tracks, all phases
**MVP:** ✅

**Responsibility:**
Activated whenever any agent calls `raise_uncertainty`. Classifies the
uncertainty by type (spec gap, tool gap, environment gap, novel situation),
routes to the appropriate resolution authority (TaskOwner for spec gaps,
FrameworkOwner for framework gaps, human:director for novel situations),
and returns the resolution to the blocked agent.

**Gate authority:**
- Owns the uncertainty log (append-only)
- Routes uncertainties to resolution authorities
- Records resolutions and closes uncertainty instances
- Aggregates uncertainty patterns (recurring uncertainty =
  structural gap signal to FrameworkOwner)

**Key tools (sketch):**
```
Universal (all 4)
append_uncertainty_log
read_uncertainty_log
request_uncertainty_resolution
submit_uncertainty_resolution_{uncertainty_id}
```

**Certainty threshold:** 0.75
(Must route even when uncertain — routing an uncertainty incorrectly
is recoverable; failing to route is not)

**Open questions:**
- Should UncertaintyOwner have write access to task specs to directly
  patch spec gaps it identifies, or should it only route? Proposed:
  route only — writing a spec patch is TaskOwner's authority.

---

### TaskOrchestrator

**Type:** ORCHESTRATOR
**user-invokable:** true
**Track / Phase:** Delivery → Execution
**MVP:** ✅

**Responsibility:**
Claims a task when it reaches `CONTEXT_READY` and coordinates the full
Execution phase: activating TaskPerformer, receiving proof submission,
activating QAOrchestrator, handling rework loops, and requesting
human approval when QA passes.

**Delegates to:** `TaskPerformer`, `QAOrchestrator`

**Key tools (sketch):**
```
Universal (all 4)
agent
claim_task_{task_id}
read_task_spec_{task_id}
read_proof_template_{task_id}
read_proof_{task_id}
read_qa_review_{task_id}
request_approval_{task_id}
```

**Certainty threshold:** 0.85

**Open questions:**
- When a rework loop exceeds a threshold (e.g., 3 rounds), should
  TaskOrchestrator automatically raise_uncertainty or continue?
  Proposed: raise_uncertainty after 3 rounds — signals structural
  problem with spec or environment, not task performer failure.

---

### QAOrchestrator

**Type:** ORCHESTRATOR
**user-invokable:** true
*(activated by Policy Engine on SUBMITTED state — not typically
user-invoked directly)*
**Track / Phase:** Delivery → Execution (QA sub-phase)
**MVP:** ✅

**Responsibility:**
Coordinates the three-reviewer QA chain for a submitted proof.
Activates ProofReviewer, ACReviewer, and EnvironmentReviewer in
parallel. Synthesises their verdicts. Submits a passing or failing
QA review. On failure, produces a consolidated findings document
for TaskPerformer.

**Delegates to:** `ProofReviewer`, `ACReviewer`, `EnvironmentReviewer`

**Key tools (sketch):**
```
Universal (all 4)
agent
read_proof_{task_id}
read_proof_template_{task_id}
read_proof_review_{task_id}
read_ac_review_{task_id}
read_env_review_{task_id}
submit_qa_review_{task_id}
```

**Certainty threshold:** 0.90
(Synthesises verdicts — must be certain before submitting PASS or FAIL)

**Open questions:**
- How does QAOrchestrator handle a split verdict (two PASS, one FAIL)?
  Current rule: any FAIL = QA_FAILED. But should a partial pass be
  recorded differently from a full fail? Proposed: record individually
  in the QA review document; outcome is still binary for state machine.

---

### DeliveryOrchestrator

**Type:** ORCHESTRATOR
**user-invokable:** true
**Track / Phase:** Delivery → Release
**MVP:** ✅

**Responsibility:**
Activated when a task reaches `APPROVED`. Coordinates the deployment
sequence: activating Deployer, monitoring deployment progress, activating
EnvironmentReviewer for post-deploy verification, and transitioning to
`DONE` when all checks pass.

**Delegates to:** `Deployer`, `EnvironmentReviewer`

**Key tools (sketch):**
```
Universal (all 4)
agent
activate_deployment_{task_id}
read_proof_{task_id}
read_qa_review_{task_id}
read_env_review_{task_id}
```

**Certainty threshold:** 0.90

**Open questions:**
- For multi-task pitches, should DeliveryOrchestrator batch deploys or
  deploy per task? Proposed for MVP: per task. Batching is a post-MVP
  optimisation.
- Staged rollout logic (canary → full) lives in the Deployer's skill
  file, not in DeliveryOrchestrator. DeliveryOrchestrator observes
  and responds to signals; it does not make rollout decisions.

---

### ContextCurator

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Delivery → Specification (SPEC_APPROVED state)
**MVP:** ✅

**Responsibility:**
When a task spec is approved, prepares a tailored context card for each
agent that will operate on the task during Execution and Release. Applies
the compression rubric (from earlier experiments) to produce minimum
sufficient context. Queries the Pattern Library for relevant patterns
per agent role. Submits `context_ready` when all cards are validated.

**Key tools (sketch):**
```
Universal (all 4)
read_task_spec_{task_id}
read_proof_template_{task_id}
read_feature_spec
read_ac
search_knowledge_base
search_patterns
write_context_card_{agent}_{task_id}
submit_context_ready_{task_id}
```

**Certainty threshold:** 0.85

**Notes:**
ContextCurator is the only agent whose input is intentionally larger
than its output — it reads widely to curate narrowly. This was
validated in Experiment 1 retro. The compression rubric (four passes)
from the earlier context curation pattern document applies here.

**Open questions:**
- Does ContextCurator write a single card per agent class, or one per
  agent instance per task? Answer: one per agent instance per task —
  ProofReviewer on task-07 gets a different card from ProofReviewer
  on task-08, even though they are the same agent class.

---

### ProofDesigner

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Delivery → Specification (concurrent with DRAFT state)
**MVP:** ✅

**Responsibility:**
Writes the proof template for a task. Reads the task spec and AC and
translates them into a set of measurable, evidence-based completion
criteria. The proof template is the task's "contract" — it defines
what evidence will constitute completion before implementation begins.

**Critical structural rule (L6 + T5):**
ProofDesigner must never be the same agent instance as TaskPerformer
for the same task. The audit log enforces this — PE-01 checks that
the `write_proof_template` actor ≠ TaskPerformer identity.

**Key tools (sketch):**
```
Universal (all 4)
read_task_spec_{task_id}
read_ac
read_feature_spec
search_patterns
write_proof_template_{task_id}
```

**Certainty threshold:** 0.85

**Notes:**
This agent class is the smart contract author of the framework.
A vague proof template produces a vague contract, which produces
unverifiable work. ProofDesigner's skill file must emphasise criterion
precision above all else: every criterion must specify the exact evidence
format, the exact passing condition, and the exact failure condition.

**Open questions:**
- For Tier 3/4 tasks, a MetaReviewer reviews the proof template before
  SPEC_APPROVED. Who is the MetaReviewer for proof templates in Tier 3?
  Proposed: a specialised `ProofTemplateReviewer` REVIEWER class. Deferred
  from MVP — Tier 2 is the MVP default.

---

### TaskPerformer

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Delivery → Execution (IN_PROGRESS state)
**MVP:** ✅

**Responsibility:**
Implements a task against its specification and proof template.
Writes a work log throughout execution. Submits a structured proof
document mapping evidence to each proof template criterion. Addresses
QA findings in rework rounds and resubmits until QA passes.

**Key tools (sketch):**
```
Universal (all 4)
read_task_spec_{task_id}
read_proof_template_{task_id}
read_qa_review_{task_id}   (for rework rounds)
append_work_log_{task_id}
search_knowledge_base
submit_proof_{task_id}
[GitHub MCP tools scoped to task branch]
```

**Certainty threshold:** 0.75
(Lower threshold — TaskPerformer should raise_uncertainty
earlier rather than guessing. Execution uncertainty is cheap;
rework is expensive.)

**Open questions:**
- Should TaskPerformer hold GitHub MCP tools directly, or should
  these be mediated by TaskOrchestrator? Proposed: TaskPerformer
  holds task-branch-scoped GitHub tools directly. Branch scope
  is enforced by the tool registration.

---

### Deployer

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Delivery → Release (DEPLOYING state)
**MVP:** ✅

**Responsibility:**
Executes the deployment sequence for an approved task. Follows the
deployment procedure defined in the environment contract. Records
each deployment step in the work log. Signals completion to
DeliveryOrchestrator for post-deploy verification.

**Key tools (sketch):**
```
Universal (all 4)
read_proof_{task_id}
read_environment_contract_{task_id}
append_work_log_{task_id}
submit_deployment_{task_id}
[Infrastructure/CI MCP tools — project-specific]
```

**Certainty threshold:** 0.90
(Deployment is high-blast-radius — high threshold before acting
without raising uncertainty)

**Open questions:**
- Infrastructure MCP tools are project-specific. The Deployer agent
  class definition will need a placeholder for project-configurable
  tools. This is the first example of a project-variant tool list —
  may need a new pattern in Agent Design Standards.

---

### TemplateAuthor

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Zone 0
**MVP:** ✅

**Responsibility:**
Writes new agent template files (`.agent.md`) from requirements
documents produced by FrameworkOwner. Conforms every template to
the Base Agent Template structure. Revises templates when AgentSpecReviewer
returns failures.

**Key tools (sketch):**
```
Universal (all 4)
read_agent_class_requirements
read_base_agent_template
read_spec_tests
write_agent_template
```

**Certainty threshold:** 0.80

---

### SpecValidator

**Type:** EXECUTOR
**user-invokable:** false
**Track / Phase:** Delivery → Specification (optional)
**MVP:** 🟡 optional

**Responsibility:**
Validates task specifications against the Agent Design Standards and
Task Specification standards before TaskOwner submits for approval.
Catches structural issues (missing proof template, vague criteria,
QA tier not set) before they block the Execution phase.

**Key tools (sketch):**
```
Universal (all 4)
read_task_spec_{task_id}
read_proof_template_{task_id}
read_agent_design_standards
submit_spec_validation_{task_id}
```

**Certainty threshold:** 0.90
(Validator — should only pass what is unambiguously correct)

**Notes:**
In the MVP, SpecValidator is optional because TaskOwner applies
the same standards when writing. SpecValidator adds value when
task volume increases and the cost of a SPEC_APPROVED task failing
in Execution (due to spec defects) rises above the cost of running
the validator.

---

### ProofReviewer

**Type:** REVIEWER
**user-invokable:** false
**Track / Phase:** Delivery → Execution (QA_IN_PROGRESS state)
**MVP:** ✅

**Responsibility:**
Verifies that the submitted proof satisfies the proof template criteria.
For each criterion in the proof template, confirms that the submitted
evidence is present, in the required format, and meets the passing
condition. Returns PASS or FAIL with criterion-level findings.

**Structural constraint (T5):**
May not hold any write tools for documents TaskPerformer writes.
Read-only access to proof and proof template. Write access only to
its own review document.

**Key tools (sketch):**
```
Universal (all 4)
read_proof_{task_id}
read_proof_template_{task_id}
submit_proof_review_{task_id}
```

**Certainty threshold:** 0.92

---

### ACReviewer

**Type:** REVIEWER
**user-invokable:** false
**Track / Phase:** Delivery → Execution (QA_IN_PROGRESS state)
**MVP:** ✅

**Responsibility:**
Verifies that the submitted proof satisfies the feature's acceptance
criteria. Where ProofReviewer checks against the proof template,
ACReviewer checks against the original AC — ensuring that the proof
template correctly captured the AC and that the proof satisfies it.

**Structural note:**
ACReviewer is the independent check on ProofDesigner's work. If the
proof template omitted or misrepresented an AC item, ACReviewer catches
it. This is T5 applied at the specification layer, not just execution.

**Key tools (sketch):**
```
Universal (all 4)
read_proof_{task_id}
read_proof_template_{task_id}
read_ac
submit_ac_review_{task_id}
```

**Certainty threshold:** 0.92

---

### EnvironmentReviewer

**Type:** REVIEWER
**user-invokable:** false
**Track / Phase:** Delivery → Execution (QA) + Release (post-deploy)
**MVP:** ✅

**Responsibility:**
Operates in two contexts:
1. **During QA (QA_IN_PROGRESS):** Verifies that the proof demonstrates
   compliance with the environment contract — correct services, correct
   versions, correct configuration, no mocked dependencies where real
   ones are required.
2. **Post-deploy (DEPLOYING):** Verifies that the deployed system
   matches the environment contract in production. Post-deploy
   verification uses different evidence than pre-deploy verification.

**Key tools (sketch):**
```
Universal (all 4)
read_proof_{task_id}
read_environment_contract_{task_id}
submit_env_review_{task_id}       (QA context)
submit_postdeploy_review_{task_id} (Release context)
```

**Certainty threshold:** 0.92

**Notes:**
EnvironmentReviewer is the only agent that operates in two distinct
states (QA_IN_PROGRESS and DEPLOYING). Its context card differs per
context — ContextCurator generates two cards for this agent class
per task, distinguished by context type.

---

### AgentSpecReviewer

**Type:** REVIEWER
**user-invokable:** false
**Track / Phase:** Zone 0
**MVP:** ✅

**Responsibility:**
Writes spec tests for proposed agent templates (from Agent Class
Requirements). Runs spec tests against finished templates produced
by TemplateAuthor. Returns PASS or FAIL with failing test evidence.
Does not write agent templates (structural separation — cannot
review own work).

**Key tools (sketch):**
```
Universal (all 4)
read_agent_class_requirements
read_base_agent_template
read_agent_template
write_spec_tests
submit_spec_test_results
```

**Certainty threshold:** 0.92

---

## Deferred Agent Classes

These agent classes are designed at concept level but not specified in
sufficient detail for implementation. They are recorded here to prevent
duplication and to preserve design context.

### Discovery Track — Problem Phase
- `ProblemResearcher` — researches the problem space before solution
  ideation
- `PersonaEmpathiser` — builds evidence-based personas of affected
  people
- `ResearchSynthesiser` — synthesises research into validated problem
  statement and success metrics (REVIEWER type — synthesises, does not
  gather)

### Discovery Track — Shaping Phase
- Six ideation agents (de Bono thinking hat orientations) — names and
  exact cognitive orientations TBD pending dedicated design session
- `IdeaSynthesiser` — aggregates six-perspective ideation outputs
- `IdeaPrioritiser` — evaluates candidates against problem + appetite
- `Prototyper` — builds minimum viable proof-of-approach
- `UserValidator` — validates prototype against persona needs

### Operations Track
- `SystemMonitor` — observes live system behaviour and captures signals
- `FindingTriager` — classifies operations findings and routes to
  Discovery or Delivery

---

## Roster Evolution Rules

1. **Adding a class:** New agent classes are added through the Zone 0
   process (Agent Creation Policy v0.1). A class does not appear in this
   roster as anything other than DEFERRED until its Zone 0 process is
   complete and FrameworkOwner approves.

2. **Renaming a class:** Renames require a framework manifest entry
   recording the old name, new name, and reason. All prior document
   references are updated. Current rename on record: `QAExecutor` →
   `QAOrchestrator` (this document).

3. **Retiring a class:** A retired class is marked DEPRECATED in this
   roster and RETIRED in its class definition. It does not receive new
   task activations. Existing activations complete against the retired
   spec.

4. **This document is not the class definition.** Each entry here has
   (or needs) a corresponding full class definition at
   `.framework/agent-classes/{agent-class}.agent-class.md`.
   The class definition is authoritative for tools, certainty thresholds,
   and pattern tags. This roster is the index.

---

## Version History

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-03-05 | Initial roster. 17 defined/needs-definition classes. 9 deferred. QAExecutor renamed QAOrchestrator. SpecValidator marked optional MVP. |