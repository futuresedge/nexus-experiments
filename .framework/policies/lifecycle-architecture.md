# Lifecycle Architecture

**Version:** 1.0
**Status:** Active
**Principles implemented:** T1, T3, T4, T5, L2, L3, L6, PF3
**Dependencies:**
  Foundation Principles v2.0
  Work Topology v1.0
  Tool Grammar v0.3
  Agent Design Standards v1.0
**Last Updated:** 2026-03-05

---

## Purpose

This document specifies the state machines that govern all work in the
Nexus Framework. It is the authoritative reference for:
- Every state a unit of work can be in
- Every valid transition between states
- Which actor triggers each transition and with which tool
- What the Policy Engine enforces at each gate
- Which agents activate on each transition

This document is not explanatory — it is prescriptive. The Work Topology
document explains why work flows this way. This document specifies exactly
how.

---

## Three Lifecycles

Three state machines operate simultaneously and are hierarchically related:

```
CYCLE lifecycle          ← temporal container (one Delivery cycle)
  └── PITCH lifecycle    ← compositional unit (one shaped pitch)
        └── TASK lifecycle   ← atomic unit (one task) ← authoritative
```

**Task is authoritative.** Pitch state is derived from its tasks' states.
Cycle state is derived from its pitches' states. The Policy Engine
evaluates task states and computes pitch and cycle states — they are
never set directly by an actor.

---

## Part 1 — Task Lifecycle

The task is the atomic unit of work. It is the unit of verification,
the unit of audit, and the unit of proof. Everything the framework
guarantees, it guarantees at the task level.

### 1.1 Task States

**Working states** — task is actively progressing:

| State | Meaning |
|---|---|
| `DRAFT` | Task spec is being written. No proof template yet. |
| `SPEC_APPROVED` | Task spec and proof template are approved. Task is ready for context preparation. |
| `CONTEXT_READY` | ContextCurator has prepared and verified context cards for all Execution agents. Task-scoped tools are registered. |
| `IN_PROGRESS` | TaskPerformer has claimed the task and is implementing. |
| `SUBMITTED` | TaskPerformer has submitted proof. Awaiting QA. |
| `QA_IN_PROGRESS` | QA chain is active. Reviewers are verifying. |
| `QA_PASSED` | All required reviewers have returned PASS. |
| `AWAITING_APPROVAL` | QA passed. Waiting for human:approver decision. |
| `APPROVED` | Human approved. Task is ready for Release. |
| `DEPLOYING` | Deployer is executing the deployment sequence. |
| `DONE` | Deployed and post-deploy verification passed. Terminal state. |

**Lateral states** — can stack onto any working state (see §1.5):

| State | Meaning |
|---|---|
| `BLOCKED` | An agent called `raise_uncertainty`. Work is halted. Stacks on current working state. |
| `AWAITING_HUMAN` | An agent called a `request_` tool requiring human action. Stacks on current working state. |

**Terminal states** — task will not progress further:

| State | Meaning |
|---|---|
| `DONE` | Successfully deployed and verified. |
| `REJECTED` | human:approver explicitly rejected at `AWAITING_APPROVAL`. |
| `CANCELLED` | FrameworkOwner cancelled the task at any point. |

---

### 1.2 Task State Diagram

```
                    ┌─────────────────────────────────────────────────┐
                    │  LATERAL STATES (stack on any working state)     │
                    │                                                  │
                    │  BLOCKED          ◄── raise_uncertainty          │
                    │    │                    (any agent)              │
                    │    │ uncertainty resolved                        │
                    │    ▼                                             │
                    │  [resume prior state]                            │
                    │                                                  │
                    │  AWAITING_HUMAN   ◄── request_{x}               │
                    │    │                    (any agent)              │
                    │    │ human responds                              │
                    │    ▼                                             │
                    │  [resume prior state]                            │
                    └─────────────────────────────────────────────────┘

DRAFT
  │  TaskOwner: write_task_spec
  │  ProofDesigner: write_proof_template_{task_id}
  │  TaskOwner: submit_task_spec_{task_id}
  ▼
SPEC_APPROVED
  │  ContextCurator: submit_context_ready_{task_id}
  ▼
CONTEXT_READY
  │  [Policy Engine registers task-scoped tools]
  │  [Policy Engine activates TaskOrchestrator]
  │  TaskOrchestrator: claim_task_{task_id}
  ▼
IN_PROGRESS ◄────────────────────────────────────────┐
  │  TaskPerformer: append_work_log_{task_id}         │
  │  TaskPerformer: submit_proof_{task_id}            │
  ▼                                                   │
SUBMITTED                                             │
  │  [Policy Engine activates QAExecutor]             │
  ▼                                                   │
QA_IN_PROGRESS                                        │
  │  ProofReviewer: submit_proof_review_{task_id}     │
  │  ACReviewer: submit_ac_review_{task_id}           │
  │  EnvironmentReviewer: submit_env_review_{task_id} │
  │  [Policy Engine: all three must return]           │
  │                                                   │
  ├─── any FAIL ──► QA_FAILED ──────────────────────►┘
  │                  (rework loop — findings returned
  │                   to TaskPerformer, round N+1)
  │
  ▼ all PASS
QA_PASSED
  │  QAExecutor: submit_qa_review_{task_id}
  │  [Policy Engine: activates approval request]
  ▼
AWAITING_APPROVAL
  │  human:approver approves
  ▼
APPROVED
  │  [Policy Engine activates DeliveryOrchestrator]
  ▼
DEPLOYING
  │  Deployer: submit_deployment_{task_id}
  │  EnvironmentReviewer: submit_postdeploy_review_{task_id}
  ▼
DONE ◄── terminal

AWAITING_APPROVAL
  │  human:approver rejects
  ▼
REJECTED ◄── terminal

[any state]
  │  FrameworkOwner: cancel_task_{task_id}
  ▼
CANCELLED ◄── terminal
```

---

### 1.3 Task Transition Table

Each row is one state transition. Columns:

- **From / To** — state transition
- **Tool** — the MCP tool that triggers the transition (atomic: write +
  state change + stream event happen together or not at all)
- **Actor** — the agent or human that holds the tool
- **Pre-conditions** — what the Policy Engine checks before permitting
  the transition. If any condition fails, the tool returns a typed error;
  the state does not change
- **Side effects** — what happens as a result of the transition

---

**Specification phase transitions:**

| From → To | Tool | Actor | Pre-conditions | Side effects |
|---|---|---|---|---|
| *(none)* → `DRAFT` | `create_task_{task_id}` | TaskOwner | Feature is in `COMMITTED` state; task decomposition document exists | Audit entry; stream event: *task-XX created*; task-scoped tools registered (read only) |
| `DRAFT` → `SPEC_APPROVED` | `submit_task_spec_{task_id}` | TaskOwner | Task spec document exists and is non-empty; proof template document exists and is non-empty; all proof template criteria have explicit evidence requirements (no vague criteria) | Audit entry; stream event: *task-XX spec approved*; context card preparation triggered |
| `SPEC_APPROVED` → `CONTEXT_READY` | `submit_context_ready_{task_id}` | ContextCurator | Context cards exist for all required Execution agents (TaskOrchestrator, TaskPerformer, QAExecutor, all three reviewers); cards have passed ContextCurator's internal validation | Audit entry; stream event: *task-XX context ready*; task-scoped execution tools registered; TaskOrchestrator activation event emitted |

---

**Execution phase transitions:**

| From → To | Tool | Actor | Pre-conditions | Side effects |
|---|---|---|---|---|
| `CONTEXT_READY` → `IN_PROGRESS` | `claim_task_{task_id}` | TaskOrchestrator | Task is in `CONTEXT_READY`; no other agent holds an active claim | Audit entry; stream event: *task-XX in progress*; TaskPerformer activation event emitted; round counter initialised to 1 |
| `IN_PROGRESS` → `SUBMITTED` | `submit_proof_{task_id}` | TaskPerformer | Proof document is non-empty; all proof template criteria have corresponding evidence entries in the proof; round counter ≥ 1 | Audit entry; stream event: *task-XX proof submitted (round N)*; QAExecutor activation event emitted |
| `SUBMITTED` → `QA_IN_PROGRESS` | `activate_qa_{task_id}` | QAExecutor | Task is in `SUBMITTED`; QAExecutor holds context card for this task | Audit entry; stream event: *task-XX QA in progress*; ProofReviewer, ACReviewer, EnvironmentReviewer activation events emitted (parallel) |
| `QA_IN_PROGRESS` → `QA_FAILED` | `submit_qa_review_{task_id}` (outcome: FAIL) | QAExecutor | All three reviewer verdicts received; at least one FAIL verdict present; findings document is non-empty (mandatory on FAIL) | Audit entry; stream event: *task-XX QA failed (round N) — [summary of findings]*; task state → `QA_FAILED`; round counter incremented; findings delivered to TaskPerformer context; TaskPerformer re-activation event emitted |
| `QA_FAILED` → `IN_PROGRESS` | *(automatic)* | Policy Engine | QA_FAILED state reached | Automatic transition — no actor triggers this. Task returns to IN_PROGRESS immediately. Policy Engine delivers findings to TaskPerformer's next context card. |
| `QA_IN_PROGRESS` → `QA_PASSED` | `submit_qa_review_{task_id}` (outcome: PASS) | QAExecutor | All three reviewer verdicts received; all three are PASS | Audit entry; stream event: *task-XX QA passed (round N)*; approval request emitted to human:approver |
| `QA_PASSED` → `AWAITING_APPROVAL` | `request_approval_{task_id}` | QAExecutor | Task is in `QA_PASSED` | Audit entry; priority stream event: *task-XX awaiting your approval — QA passed (round N)* |

---

**Human approval transition:**

| From → To | Tool | Actor | Pre-conditions | Side effects |
|---|---|---|---|---|
| `AWAITING_APPROVAL` → `APPROVED` | `approve_task_{task_id}` | human:approver | Task is in `AWAITING_APPROVAL`; human:approver explicitly calls tool (no timeout fallback) | Audit entry; stream event: *task-XX approved*; DeliveryOrchestrator activation event emitted |
| `AWAITING_APPROVAL` → `REJECTED` | `reject_task_{task_id}` | human:approver | Task is in `AWAITING_APPROVAL`; rejection reason is non-empty | Audit entry; stream event: *task-XX rejected — [reason]*; task-scoped tools revoked |

---

**Release phase transitions:**

| From → To | Tool | Actor | Pre-conditions | Side effects |
|---|---|---|---|---|
| `APPROVED` → `DEPLOYING` | `activate_deployment_{task_id}` | DeliveryOrchestrator | Task is in `APPROVED`; all dependent tasks are `DONE` | Audit entry; stream event: *task-XX deploying*; Deployer activation event emitted |
| `DEPLOYING` → `DONE` | `submit_deployment_{task_id}` | Deployer | Deployment commands completed successfully; EnvironmentReviewer post-deploy verdict is PASS | Audit entry; stream event: *task-XX done*; task-scoped tools revoked; Learning Layer trigger: terminal reports requested from all agents |

---

**Terminal transitions:**

| From → To | Tool | Actor | Pre-conditions | Side effects |
|---|---|---|---|---|
| *any* → `CANCELLED` | `cancel_task_{task_id}` | FrameworkOwner | Cancellation reason is non-empty | Audit entry; priority stream event: *task-XX cancelled — [reason]*; all task-scoped tools revoked; agents active on task receive cancellation signal |

---

### 1.4 Rework Loop Detail

The rework loop is a normal part of Execution, not an exceptional state.
Every QA_FAILED → IN_PROGRESS cycle is a round. The audit log records
every round. The stream event on QA_FAILED includes the round number and
a summary of findings.

```
Round tracking:
  Task created:                    round = 1
  First submit_proof:              round 1
  First QA_FAILED:                 round = 2 (incremented on failure)
  Second submit_proof:             round 2
  QA_PASSED (second attempt):      round 2
```

**What the rework loop record shows:**
The audit log for a two-round task looks like this:
```
claim_task_task07          TaskOrchestrator   10:15  IN_PROGRESS
submit_proof_task07        TaskPerformer      10:45  SUBMITTED (round 1)
activate_qa_task07         QAExecutor         10:46  QA_IN_PROGRESS
submit_proof_review_task07 ProofReviewer      11:02  verdict: PASS
submit_ac_review_task07    ACReviewer         11:04  verdict: PASS
submit_env_review_task07   EnvironmentReviewer 11:06 verdict: FAIL
submit_qa_review_task07    QAExecutor         11:07  QA_FAILED (round 1)
                                                     findings: env contract
                                                     mismatch on SMTP config
submit_proof_task07        TaskPerformer      11:38  SUBMITTED (round 2)
activate_qa_task07         QAExecutor         11:39  QA_IN_PROGRESS
submit_proof_review_task07 ProofReviewer      11:52  verdict: PASS
submit_ac_review_task07    ACReviewer         11:54  verdict: PASS
submit_env_review_task07   EnvironmentReviewer 11:55 verdict: PASS
submit_qa_review_task07    QAExecutor         11:56  QA_PASSED (round 2)
```

The record is complete and unambiguous: what failed, who found it,
when it was corrected, how long the correction took.

---

### 1.5 Lateral States — BLOCKED and AWAITING_HUMAN

Lateral states are not positions in the linear state machine. They stack
on top of the current working state. When a lateral state resolves, the
task returns to exactly the working state it was in — not a generic
recovery state.

**BLOCKED:**
```
Trigger:     raise_uncertainty called by any agent on this task
Entry:       State transitions to BLOCKED (prior state preserved)
             Priority stream event fires to human:director
             UncertaintyOwner activates
             All agent activations for this task are suspended
             
Resolution:  UncertaintyOwner records resolution
             Task returns to prior working state
             Agent that raised uncertainty receives resolution
             via updated context card
             Audit entries: raise_uncertainty call + resolution record
```

**AWAITING_HUMAN:**
```
Trigger:     request_{x} tool called by any agent on this task
Entry:       State transitions to AWAITING_HUMAN (prior state preserved)
             Stream event fires to human:director identifying the request
             No suspension of other agents unless the request is blocking
             
Resolution:  Human responds via the appropriate tool
             Task returns to prior working state
             Requesting agent receives response
             Audit entries: request call + human response
```

**Important:** There is no timeout on either lateral state. A task in
BLOCKED or AWAITING_HUMAN stays there until resolved. The system does not
resume automatically. This is the structural implementation of L2
(irreversibility demands presence) — when an agent is blocked, it waits
for human judgment, not for a timeout to fire.

---

### 1.6 QA Tier Variations

The base Execution phase models Tier 2 QA (the default for the MVP).
Higher tiers add states between `SPEC_APPROVED` and `IN_PROGRESS` and
add parallel reviewer paths within `QA_IN_PROGRESS`.

| Tier | Additional states | Additional actors | Gate change |
|---|---|---|---|
| **Tier 0** | None | None | No QA gate — stream event only |
| **Tier 1** | None | Single QA reviewer (no split) | One reviewer verdict sufficient |
| **Tier 2** (MVP default) | None | ProofReviewer + ACReviewer + EnvironmentReviewer in parallel | All three must PASS |
| **Tier 3** | `PROOF_TEMPLATE_IN_REVIEW` between `DRAFT` and `SPEC_APPROVED` | MetaReviewer validates proof template before TaskOwner approves | Proof template is independently verified before execution |
| **Tier 4** | Tier 3 states + `AWAITING_HUMAN` forced at `QA_PASSED` | MetaReviewer + human gate mandatory | Human must approve before `AWAITING_APPROVAL` emits |

**Tier assignment rule:**
TaskOwner proposes a QA tier when creating the task. The tier is based on
Blast Radius (BR) and Novelty (NV) scores from the Agent Creation Policy.
The QA tier is set at task creation time and cannot be downgraded during
execution.

---

## Part 2 — Pitch Lifecycle

A shaped pitch is the unit of commitment from the Discovery track to the
Delivery track. Its lifecycle tracks the progress of the work it represents
in aggregate.

### 2.1 Pitch States

| State | Meaning |
|---|---|
| `SHAPED` | Pitch is complete and ready for commitment |
| `COMMITTED` | human:director has committed to building it; enters Delivery |
| `IN_SPECIFICATION` | TaskOwner is decomposing into tasks |
| `SPECIFIED` | All tasks have approved specs and proof templates |
| `IN_DELIVERY` | At least one task is in Execution |
| `IN_RELEASE` | All tasks are `APPROVED`; Release phase active |
| `RELEASED` | All tasks are `DONE`; pitch is live in production |
| `DEFERRED` | human:director chose not to commit; parked in Discovery |
| `ABANDONED` | Explicitly abandoned; will not be built |

### 2.2 Pitch State Derivation Rules (Policy Engine)

Pitch state is computed from its constituent task states. It is never
set directly by an actor.

```
IF all tasks are DONE             → pitch is RELEASED
IF any task is DEPLOYING          → pitch is IN_RELEASE
IF all tasks are APPROVED         → pitch is IN_RELEASE
IF any task is IN_PROGRESS,
   SUBMITTED, QA_IN_PROGRESS,
   QA_PASSED, or AWAITING_APPROVAL → pitch is IN_DELIVERY
IF all tasks are SPEC_APPROVED
   or CONTEXT_READY               → pitch is SPECIFIED
IF any task is DRAFT              → pitch is IN_SPECIFICATION
IF no tasks exist yet             → pitch is COMMITTED
```

The SHAPED → COMMITTED transition is the only pitch transition triggered
by an actor:

| From → To | Tool | Actor | Pre-conditions |
|---|---|---|---|
| `SHAPED` → `COMMITTED` | `commit_pitch_{pitch_id}` | human:director | Appetite is declared; proof-of-completion sketch exists; no open uncertainties on this pitch |
| `SHAPED` → `DEFERRED` | `defer_pitch_{pitch_id}` | human:director | Deferral reason is non-empty |

---

## Part 3 — Cycle Lifecycle

A Delivery cycle is the temporal container for one or more committed
pitches. It tracks progress at the highest level of the Delivery track.

### 3.1 Cycle States

| State | Meaning |
|---|---|
| `FORMING` | Pitches being selected for this cycle |
| `ACTIVE` | At least one pitch is in delivery |
| `RELEASING` | All pitches are in Release phase |
| `COMPLETE` | All pitches are RELEASED |
| `RETRO_IN_PROGRESS` | Cycle retro is being written |
| `CLOSED` | Retro is complete; all learnings captured |

### 3.2 Cycle State Derivation Rules

```
IF all pitches are RELEASED         → cycle is COMPLETE
IF any pitch is IN_RELEASE          → cycle is RELEASING
IF any pitch is IN_DELIVERY         → cycle is ACTIVE
IF all pitches are COMMITTED        → cycle is FORMING
```

**Cycle trigger (deferred decision):**
What starts a new Delivery cycle — appetite-based, time-boxed, or
human:director directive — is an open design decision recorded in
Work Topology Research Notes. For the MVP, cycles are started by
human:director explicitly using `create_cycle`.

The COMPLETE → RETRO_IN_PROGRESS → CLOSED transitions are the
Learning Layer integration points (see Part 5).

---

## Part 4 — Agent Activation Matrix

This table maps states to which agents are active in that state.
"Active" means the agent holds task-scoped tools and is expected
to be making tool calls. "On-call" means the agent may be activated
by a lateral state event but is not actively working.

| State | Active | On-call |
|---|---|---|
| `DRAFT` | TaskOwner, ProofDesigner | UncertaintyOwner |
| `SPEC_APPROVED` | ContextCurator | UncertaintyOwner |
| `CONTEXT_READY` | TaskOrchestrator | UncertaintyOwner |
| `IN_PROGRESS` | TaskOrchestrator, TaskPerformer | UncertaintyOwner |
| `SUBMITTED` | QAExecutor | UncertaintyOwner |
| `QA_IN_PROGRESS` | QAExecutor, ProofReviewer, ACReviewer, EnvironmentReviewer | UncertaintyOwner |
| `QA_FAILED` | *(automatic transition — no agent)* | UncertaintyOwner |
| `QA_PASSED` | QAExecutor | UncertaintyOwner |
| `AWAITING_APPROVAL` | human:approver | UncertaintyOwner |
| `APPROVED` | DeliveryOrchestrator | UncertaintyOwner |
| `DEPLOYING` | DeliveryOrchestrator, Deployer, EnvironmentReviewer | UncertaintyOwner |
| `DONE` | FrameworkOwner (Learning Layer) | — |
| `BLOCKED` | UncertaintyOwner | — |
| `AWAITING_HUMAN` | human:director | — |

**Activation events:**
Agents are not polling for work. They are activated by events from the
Policy Engine when a state transition they are responsible for is reached.
An agent that receives no activation event has no task-scoped tools and
cannot operate on a task. This is the structural implementation of T3
(authority is structural) — capability is assigned at activation, not
by declaration.

---

## Part 5 — Learning Layer Integration

The Learning Layer is triggered at three points in the task lifecycle.
These are not optional — they are enforced by the Policy Engine.

### Terminal report trigger

**When:** Any task reaches `DONE`, `REJECTED`, or `CANCELLED`.
**What:** Policy Engine emits a terminal report request to every agent
that was active on this task.
**Tool:** `submit_terminal_report_{task_id}` (held by every agent class)
**Contents required:**
- Patterns applied (with references to Pattern Library entries)
- Uncertainties raised (with resolution outcomes)
- Efficiency metrics (total tokens, steps, rework rounds)
- What worked (evidence-based, not opinion)
- What failed or was difficult (evidence-based)
- Candidate patterns (zero or more — structured, not free text)

**Enforcement:** A task cannot close its task-scoped tools until all
active agents have submitted terminal reports. An agent that does not
submit a terminal report within the response window causes the task
to enter `AWAITING_HUMAN` — a human must investigate.

### Task retro trigger

**When:** All terminal reports received for a task.
**What:** TaskOrchestrator aggregates reports into a task retro document.
**Tool:** `submit_task_retro_{task_id}`
**Contents:** Aggregate efficiency metrics, pattern summary, candidate
patterns from multiple agents (duplicates surfaced as corroboration),
structural gaps identified.

### Cycle retro trigger

**When:** Cycle transitions from `COMPLETE` to `RETRO_IN_PROGRESS`.
**What:** FrameworkOwner aggregates all task retros for the cycle.
**Tool:** `submit_cycle_retro_{cycle_id}`
**Contents:** Cycle-level metrics, recurring uncertainty patterns (same
uncertainty raised across multiple tasks = structural gap), pattern
promotion candidates, anti-pattern candidates, framework evolution
proposals.

After cycle retro submission, FrameworkOwner evaluates pattern
promotion candidates against the Pattern Library evidence thresholds.
Candidates meeting threshold are promoted. The cycle then transitions
to `CLOSED`.

---

## Part 6 — Policy Engine Rules (MVP)

The Policy Engine is the automated enforcement layer. In the MVP it
implements exactly these rules and no others. Rules are evaluated
before any state transition executes.

### Pre-condition rules (block invalid transitions)

```
RULE PE-01
  A task may not transition to SPEC_APPROVED unless:
  - task_spec document exists and is non-empty
  - proof_template document exists and is non-empty
  - all proof_template criteria contain explicit evidence_required field
  - proof_template was authored by ProofDesigner, not TaskPerformer
    (checked against audit log: write_proof_template actor ≠ TaskPerformer)

RULE PE-02
  A task may not transition to CONTEXT_READY unless:
  - context cards exist for: TaskOrchestrator, TaskPerformer,
    QAExecutor, ProofReviewer, ACReviewer, EnvironmentReviewer
  - each card has a non-empty task_brief and at least one pattern
    reference or explicit "no applicable patterns" declaration

RULE PE-03
  A task may not transition to SUBMITTED unless:
  - proof document exists and is non-empty
  - proof contains one evidence_entry per criterion in the proof_template
    (no missing evidence entries — partial proofs are rejected)

RULE PE-04
  A task may not transition to QA_PASSED unless:
  - all three reviewer submissions exist:
    proof_review, ac_review, env_review
  - all three have outcome: PASS
  - any FAIL verdict causes QA_FAILED transition instead

RULE PE-05
  A task may not transition to APPROVED unless:
  - QA_PASSED state was reached by the submit_qa_review tool
    (not by any other means — prevents state forgery)
  - human:approver tool call is the trigger (no automated approval)

RULE PE-06
  A task may not transition to DONE unless:
  - submit_deployment succeeded (Deployer tool call exists in audit log)
  - submit_postdeploy_review exists with outcome: PASS
    (EnvironmentReviewer must verify post-deploy, not pre-deploy)

RULE PE-07
  A task may not close task-scoped tools (reach final terminal state)
  unless terminal reports exist from all agents that were active
  on the task (verified against activation event log)
```

### Derivation rules (compute pitch and cycle states)

```
RULE PE-08  Pitch state is computed from task states per §2.2
RULE PE-09  Cycle state is computed from pitch states per §3.2
```

### Activation rules (trigger agent activation events)

```
RULE PE-10  On CONTEXT_READY: emit TaskOrchestrator activation event
RULE PE-11  On SUBMITTED: emit QAExecutor activation event
RULE PE-12  On QA_FAILED: emit TaskPerformer activation event with
            findings attached (automatic IN_PROGRESS transition)
RULE PE-13  On QA_PASSED: emit approval request to human:approver stream
RULE PE-14  On APPROVED: emit DeliveryOrchestrator activation event
RULE PE-15  On DONE/REJECTED/CANCELLED: emit terminal report requests
            to all agents active on the task
RULE PE-16  On BLOCKED: emit priority event to human:director stream
            and UncertaintyOwner activation event
```

---

## Part 7 — Task-Scoped Tool Registration

Task-scoped tools are dynamically registered and revoked by the
Policy Engine. They do not exist until needed, and they do not persist
after their scope closes.

### Registration events

| Event | Tools registered |
|---|---|
| `create_task_{task_id}` | `read_task_spec_{task_id}` for TaskOwner |
| `SPEC_APPROVED` state reached | Read tools for context card agents |
| `CONTEXT_READY` state reached | Full execution tool set for all Execution agents |
| `SUBMITTED` state reached | QA tool set for QAExecutor and three reviewers |
| `APPROVED` state reached | Deployment tools for DeliveryOrchestrator and Deployer |

### Revocation events

| Event | Tools revoked |
|---|---|
| `REJECTED` terminal state | All task-scoped tools |
| `CANCELLED` terminal state | All task-scoped tools |
| Task-scoped tools closed (post terminal reports) | All task-scoped tools |

**Invariant:** No agent holds a task-scoped tool for a task it is not
currently active on. The Nexus server enforces this at tool call time —
a call to a revoked tool returns a typed error, not a permission error.
The error message includes the current task state so the caller knows why.

---

## Part 8 — Audit Log Schema (Lifecycle Fields)

Every state transition produces an audit entry with these fields:

```sql
audit_log
  id                UUID        PRIMARY KEY
  timestamp         TIMESTAMPTZ NOT NULL
  task_id           TEXT        NOT NULL
  actor             TEXT        NOT NULL  -- agent name or "human:approver"
  tool              TEXT        NOT NULL  -- exact tool name from grammar
  from_state        TEXT        NOT NULL  -- state before transition
  to_state          TEXT        NOT NULL  -- state after transition
  round             INTEGER     NOT NULL DEFAULT 1
  document_type     TEXT                 -- if tool writes a document
  document_hash     TEXT                 -- SHA-256 of document content
  token_count_in    INTEGER              -- efficiency metric
  token_count_out   INTEGER              -- efficiency metric
  latency_ms        INTEGER              -- efficiency metric
  uncertainty_id    UUID                 -- FK if this is a BLOCKED entry
  notes             TEXT                 -- free text, actor-supplied
  prior_entry_id    UUID        FK       -- chain-of-custody link
```

**The `prior_entry_id` field is the chain-of-custody mechanism.** Every
audit entry references the entry that caused it to be possible. For example,
a `submit_proof` entry references the `claim_task` entry that placed the
task in `IN_PROGRESS`. This makes causal chains traceable without
reconstructing the full history from timestamps alone.

---

## Part 9 — State Machine Invariants

These invariants must hold at all times. The Policy Engine enforces them.
If any invariant is violated, the system emits a priority stream event
to human:director and halts the affected task.

```
INV-01  A task has exactly one working state at any time.
        Lateral states stack on working states; they do not replace them.

INV-02  A task's working state advances forward only.
        The only backward transition is QA_FAILED → IN_PROGRESS (rework).
        No other backward transition is valid.

INV-03  No agent holds both the submit_proof and submit_qa_review tool
        for the same task. (T5 — no actor judges own work)

INV-04  The proof_template author (from audit log) is never the same
        actor as the TaskPerformer for the same task. (T5 + L6)

INV-05  Every state transition has exactly one audit entry.
        A transition without an audit entry is invalid and must be
        treated as a system fault. (T4)

INV-06  A task in DONE, REJECTED, or CANCELLED state has no active
        task-scoped tools. All tools are revoked before the terminal
        state is fully closed.

INV-07  A task in BLOCKED state has no active agent executions except
        UncertaintyOwner. All other activations are suspended.

INV-08  Round counter is monotonically increasing.
        It can only increment, never decrement.
```

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-05 | Initial. Three-lifecycle model (Task, Pitch, Cycle). Full task state machine with transition table. Policy Engine rules (MVP). Agent activation matrix. Audit log schema. Nine state machine invariants. |