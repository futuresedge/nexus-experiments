# Work Topology

**Version:** 1.0
**Status:** Active
**Principles implemented:** L5, L6, T1, T5, PF2, PF3, L2, L3, L4, T4
**Dependencies:**
  [Foundation Principles v2.0]()
  Tool Grammar v0.3
  Agent Design Standards v1.0
**Last Updated:** 2026-03-05

---

## Purpose

This document describes how work moves through the Nexus Framework —
from identifying a problem worth solving through to operating the
solution in production and feeding learnings back into the next cycle.

It defines three tracks, one pre-product phase, and one cross-cutting
learning layer. Tracks are not sequential phases — multiple tracks run
simultaneously in a mature product. The relationship between tracks
is explicit and governed: Discovery feeds Delivery, Operations feeds
Discovery, and the Learning Layer feeds everything.

**What this document is:**
- The authoritative map of how work flows in this framework
- The reference for which agents are active in which phase
- The source of truth for track and phase boundaries

**What this document is not:**
- An agent class specification (see Agent Design Standards)
- A tool specification (see Tool Grammar)
- A state machine specification (see Task Lifecycle, a forthcoming document)

---

## The Map

```
PRE-PRODUCT
  Bootstrap

DISCOVERY TRACK ─────────────────────────────────────────────────────
  Problem                    Shaping
  ──────────────────         ──────────────────
  What problem?              What to build?
  For whom?                  How much is it worth?
  Validated output           Shaped pitch output
              │                        │
              └────────────────────────┘
                             │
                   [Human commitment gate]
                             │
                             ▼
DELIVERY TRACK ─────────────────────────────────────────────────────
  Specification         Execution              Release
  ──────────────────    ──────────────────     ──────────────────
  Decompose pitch       Implement, verify,     Deploy, document,
  into tasks.           iterate.               validate with users.
  Proof templates       QA gates throughout.   Human approval gate.
  defined first.                               Staged rollout.
              │                                        │
              └────────────────────────────────────────┘
                                                       │
                                            [Human release gate]
                                                       │
                                                       ▼
OPERATIONS TRACK ────────────────────────────────────────────────────
  Monitor                              Optimise
  ──────────────────────               ──────────────────────
  Observe live behaviour.              Triage findings.
  Capture bugs and signals.            Feed improvements back
                                       to Discovery track.

LEARNING LAYER ─────────────────────────────────────────────────────
  Cuts across all tracks. Not a phase. No start, no end.
  Agent terminal reports → task retros → cycle retros → pattern promotion
```

---

## Pre-Product: Bootstrap

### Purpose

Bootstrap is the one-time configuration of the Nexus Framework for a
specific project. It is Zone 0 work. Its output is a framework instance
that is ready to run work, not a product or feature.

Bootstrap does not produce any product artefacts. It produces the
infrastructure within which product work can happen.

### What happens in Bootstrap

- Framework Owner configures the Nexus server for this project
- Tech stack is declared (informs which patterns are relevant)
- Pattern Library is seeded with known-good patterns for this stack
- Core agent classes are confirmed or adapted for the domain
- Project-level environment contract is written
- Observable stream and audit log are verified functional

### Bootstrap is complete when

- FrameworkOwner can activate and receive a context card
- Pattern Library contains at least one verified pattern for this domain
- The environment contract covers the project's tech stack and
  deployment targets
- All core agent classes (MVP roster, see below) are confirmed active

### Principles in play

- **T4 (all actions witnessed):** The audit log is functional before
  any product work begins. Bootstrap actions are the first entries.
- **L4 (context is local, knowledge is global):** Pattern Library
  is seeded globally. Individual agent context cards are generated
  per task, not per project.
- **P2 (deliberate complementarity):** Bootstrap is human-directed.
  FrameworkOwner provides structure, not decisions.

---

## Discovery Track

### Purpose

Discovery runs continuously ahead of the Delivery track. Its job is to
ensure that the work entering Delivery is worth building, well-understood,
and scoped to a declared appetite. Work that has not been through Discovery
must not enter Delivery.

Discovery does not produce code or deployable artefacts. It produces
decisions: validated problems and shaped pitches that are ready for
commitment.

Discovery runs in parallel with Delivery and Operations in a mature
product. In a new product, it runs first and establishes enough validated
problems for the first Delivery cycle.

### Phase 1 — Problem

**Question this phase answers:** What problem are we solving, and for
whom?

**Why this phase exists (L5 — problem precedes solution):**
The most expensive failure in knowledge work is solving the wrong problem
correctly. This phase exists structurally to prevent that failure. Work
does not advance to Shaping until the problem is understood and validated.

**Activities:**
- Research the problem space — what is known, what is assumed, what
  is unknown
- Understand the people affected — who experiences this problem, in
  what context, with what consequences
- Synthesise findings into a validated problem statement and success
  metrics
- Explicitly confirm what is out of scope

**Outputs:**
- Validated problem statement (the problem to solve, not the solution)
- Persona set (who experiences this problem)
- Success metrics (how will we know the problem is solved?)
- Out-of-scope declaration (what this does NOT address)

**Gate condition — Problem is validated when:**
- The problem statement describes a real, observable situation
  (not a desired feature or a solution in disguise)
- At least one persona exists with evidence (not assumed)
- Success metrics are measurable independently of the solution
- The out-of-scope declaration exists and is non-empty

**Human gate:** human:director confirms the problem is worth pursuing
before Shaping begins. This is a resource allocation decision —
irreversible in the sense that it consumes appetite (L2).

**Agents active in this phase:**
- Problem exploration agent cluster (design pending — see Research
  Notes at end of document)
- UncertaintyOwner (on raise_uncertainty)
- FrameworkOwner (for framework-level pattern capture)

---

### Phase 2 — Shaping

**Question this phase answers:** What should we build, and how much
is it worth?

**Why this phase exists (PF2 — validate before you scale):**
Shaping resolves ambiguity before commitment. Work that enters Delivery
with unresolved ambiguity produces raise_uncertainty events in Execution,
which are expensive. Shaping makes ambiguity visible and cheap to resolve.

The appetite concept (borrowed from Shape Up) is structural here: before
shaping begins, declare how much work this problem is worth. The solution
must fit within that appetite. Appetite constrains scope before execution
begins — not during it.

**Activities:**
- Explore solution approaches (multiple, not just the first)
- Evaluate approaches against the problem statement and success metrics
- Commit to a single approach with declared appetite
- Resolve enough ambiguity that a ProofDesigner can write an
  unambiguous proof template
- Identify known risks and unknowns before commitment

**Outputs:**
- Shaped pitch: a concise, unambiguous description of the solution
  approach, scoped to the declared appetite
- Appetite declaration (how much work is this worth?)
- Risk register (what could go wrong, what is still unknown)
- Proof-of-completion sketch (what would prove this solved the problem?)

**The definition of a shaped pitch:**
A shaped pitch is ready for Delivery when a ProofDesigner can read it
and write an unambiguous proof template without needing to ask
clarifying questions. If the ProofDesigner would raise_uncertainty,
the pitch is not shaped.

**Gate condition — Pitch is ready for commitment when:**
- Solution approach is declared and scoped to appetite
- Ambiguities are resolved or explicitly accepted as risks
- Proof-of-completion sketch exists
- A ProofDesigner can translate it into a proof template without
  raising uncertainty (verified by FrameworkOwner review)

**Human gate:** human:director commits to building the shaped pitch
(L2 — irreversible resource commitment). No pitch enters Delivery
without explicit commitment.

**Agents active in this phase:**
- Ideation agent cluster (design pending — see Research Notes)
- FrameworkOwner (pattern Library consultation and capture)
- UncertaintyOwner (on raise_uncertainty)

---

## Delivery Track

### Purpose

Delivery turns committed shaped pitches into deployed, verified software.
It runs in cycles. Each cycle takes one or more shaped pitches from
commitment to production.

Delivery is the most structured track — it has the tightest state machine,
the most defined agent roster, and the most explicit gate conditions. This
is intentional: Delivery is where the most irreversible actions occur
(deployment, external user impact) and where verification failures are
most expensive.

### Phase 3 — Specification

**Question this phase answers:** What exactly does each task require,
and what will prove it is done?

**Why this phase exists (L6 — definition precedes execution):**
No task enters Execution without a proof template. The proof template
is the contract. Writing it before execution forces clarity on what
"done" means. Ambiguities discovered during specification are cheap
to resolve. Ambiguities discovered during execution are expensive.

**Activities:**
- Decompose the shaped pitch into independently completable tasks
- Write a task specification for each task
- ProofDesigner writes a proof template for each task independently
  of the performer who will execute it
- SpecValidator reviews task specs against framework standards
- Environment contract is confirmed for each task's scope

**Outputs (per task):**
- Task specification (what to build, constraints, dependencies)
- Proof template (what evidence proves this task is done — written
  by ProofDesigner, not TaskPerformer)
- Environment contract snapshot (what environment state is assumed)
- Task decomposition document (how tasks relate, dependencies,
  execution order)

**Critical invariant (T5 — no actor judges own work):**
The ProofDesigner and the TaskPerformer must be different agent instances.
A TaskPerformer that writes its own proof template is defining its own
completion criteria — a structural conflict of interest.

**Gate condition — Task is ready for Execution when:**
- Task specification is approved by TaskOwner
- Proof template exists and is complete (all criteria have measurable
  evidence requirements)
- Environment contract is confirmed
- No open uncertainties on this task

**Agents active in this phase:**
- TaskOwner (writes task specs, owns decomposition)
- ProofDesigner (writes proof templates)
- SpecValidator (validates specs against standards)
- ContextCurator (prepares context cards for Execution agents)
- UncertaintyOwner (on raise_uncertainty)

---

### Phase 4 — Execution

**Question this phase answers:** Does the implementation satisfy the
proof template?

**Why this phase has independent verification (T1 — verification
precedes trust):**
The TaskPerformer's submission is not trusted on assertion. An independent
QA chain verifies the proof against the template. Trust is a property of
the verification structure, not the performer's confidence.

**Activities:**
- TaskOrchestrator activates for the task, loads context card
- TaskPerformer implements against the task spec and proof template
- TaskPerformer submits proof (structured evidence, not assertion)
- QAExecutor activates three parallel reviewers:
  - ProofReviewer: does the evidence satisfy proof template criteria?
  - ACReviewer: does the proof satisfy acceptance criteria?
  - EnvironmentReviewer: does the implementation meet the environment
    contract?
- QAExecutor synthesises reviewer verdicts
- On QA_PASSED: task moves to AWAITING_APPROVAL
- On QA_FAILED: task returns to IN_PROGRESS with specific findings
  (rework loop — performer addresses findings and resubmits)
- Human approves or rejects at AWAITING_APPROVAL

**The rework loop is expected, not exceptional:**
A QA_FAILED → IN_PROGRESS → SUBMITTED cycle is a normal part of
Execution. The audit log records every round. The QA findings are
specific and actionable — the performer knows exactly what to address.
This is structurally preferable to QA that passes marginal work on
the first submission.

**Gate condition — Task is approved when:**
- All three reviewers return PASS
- QAExecutor submits passing QA review
- human:approver explicitly approves (L2 — deployment is irreversible)

**Agents active in this phase:**
- TaskOrchestrator (coordinates the execution chain)
- TaskPerformer (implements)
- QAExecutor (coordinates review chain)
- ProofReviewer (verifies proof against template)
- ACReviewer (verifies proof against acceptance criteria)
- EnvironmentReviewer (verifies environment contract compliance)
- UncertaintyOwner (on raise_uncertainty from any agent)

---

### Phase 5 — Release

**Question this phase answers:** Is the approved implementation safe
to ship to users, and does it work in production?

**Why Release is a separate phase from Execution:**
QA in Execution verifies that the implementation meets its specification
in a controlled environment. Release verifies that it works in the real
environment, for real users, at real scale. These are different questions
requiring different agents and different evidence.

**Activities:**
- DeliveryOrchestrator activates for the release
- Deployer executes staged deployment (staging → production)
- Post-deploy verification (environment contract re-evaluated in
  production context)
- User-facing documentation updated if required
- Staged rollout managed (canary, then full if metrics hold)
- User acceptance testing (where applicable)

**Gate condition — Release is complete when:**
- Deployment to production is confirmed by EnvironmentReviewer
- Post-deploy health checks pass
- human:director authorises full rollout (L2 — full production
  rollout is the most irreversible gate in the system)

**Agents active in this phase:**
- DeliveryOrchestrator (coordinates release chain)
- Deployer (executes deployment steps)
- EnvironmentReviewer (post-deploy verification)
- UncertaintyOwner (on raise_uncertainty — deployment blocks are
  high-priority)

---

## Operations Track

### Purpose

Operations runs continuously after the first Release. Its job is to
observe the live system, capture signals, triage them, and feed
improvement opportunities back into Discovery.

Operations is not a post-project phase. It is a permanent track that
runs alongside Discovery and Delivery once the product is in production.

### Phase 6 — Monitor

**Activities:**
- Observe live system behaviour (performance, errors, usage patterns)
- Capture bug reports and user feedback
- Track success metrics defined in Discovery (are we actually solving
  the problem?)
- Surface anomalies that indicate system degradation or new problems

**Outputs:**
- Bug reports (structured, with reproduction evidence)
- Performance observations
- Success metric tracking
- Improvement opportunities (candidate inputs for Discovery)

### Phase 7 — Optimise

**Activities:**
- Triage monitored findings (bug vs degradation vs improvement
  opportunity)
- Bugs with clear fix scope → enter Delivery as shaped pitches
  (they are already understood; they skip Problem phase)
- Degradation signals → enter Discovery Problem phase for root
  cause investigation
- Improvement opportunities → enter Discovery Problem phase as
  new problem candidates

**The feedback loop:**
Operations does not decide what to build. It produces evidence. Discovery
decides what the evidence means and whether it warrants a Delivery cycle.
This separation is structural: the actor that observes the problem (Operations)
is not the actor that decides whether to address it (human:director +
Discovery). (T5 applied at track level.)

**Agents active in Operations:**
*(Design pending — see Research Notes)*

---

## Learning Layer

### Purpose

The Learning Layer is not a phase or a track. It is the mechanism by which
every completed unit of work contributes to the framework's institutional
memory. It runs at every level simultaneously and has no start or end state.

The Learning Layer is the primary implementation of **L3 (knowledge
compounds)** and **L8 (knowledge is global)**. Without it, the framework
is a series of one-off executions. With it, the framework improves with
every task run.

### Structure

```
Level 1  Agent terminal report
         Every agent writes a structured report at the end of its run.
         Contents: patterns applied, uncertainties raised, efficiency
         metrics, what worked, what failed, candidate patterns.
         Produced by: every agent, every run, without exception.

Level 2  Task retro
         TaskOrchestrator aggregates all agent terminal reports
         for a completed task.
         Contents: round count, total tokens, uncertainty count,
         rework count, pattern application summary, candidate patterns
         from multiple agents.
         Produced by: TaskOrchestrator, on task completion.

Level 3  Cycle retro
         FrameworkOwner aggregates all task retros for a Delivery cycle.
         Contents: cycle-level efficiency metrics, recurring uncertainty
         patterns, pattern promotion candidates, anti-pattern candidates,
         framework gaps identified.
         Produced by: FrameworkOwner, on Release completion.

Level 4  Track retro
         human:director + FrameworkOwner aggregate cycle retros
         across a track or phase boundary.
         Contents: strategic findings, framework evolution proposals,
         agent class gaps, principle violations observed in practice.
         Produced by: human:director + FrameworkOwner, periodically.

Level 5  Pattern promotion
         FrameworkOwner evaluates candidates from Level 3 retros.
         Candidates with sufficient evidence are promoted to the
         Pattern Library as active patterns.
         Demotion: patterns that repeatedly produce QA_FAILED or
         raise_uncertainty outcomes are flagged for retirement.
```

### The Pattern Library

The Pattern Library is the framework's institutional memory. It is the
output of the Learning Layer and the input to every context card.

A pattern is not added based on a single successful use. Evidence
thresholds for promotion are defined per pattern type — the minimum
evidence required to trust that a pattern generalises beyond one case.

Patterns have a lifecycle:
```
CANDIDATE  → identified in a terminal report or retro
PROVISIONAL → promoted after minimum evidence threshold
ACTIVE      → promoted after extended evidence across multiple tasks
DEPRECATED  → flagged for retirement due to failures or obsolescence
RETIRED     → removed from active context card consideration
```

The Pattern Library is the one resource that benefits every future
project. A pattern proven in project A is available to project B
at zero cost. Over time, this is the primary source of the framework's
compounding efficiency advantage.

---

## MVP Scope

The full topology above includes phases that are not yet designed in
sufficient detail to implement. The following table records what is
and is not included in the Nexus MVP.

| Phase | MVP | Notes |
|---|---|---|
| Bootstrap | ✅ | Manual, human-directed |
| Problem | ❌ | Agent cluster not yet designed |
| Shaping | ❌ | Ideation agents not yet designed |
| Specification | ✅ | Core agent roster complete |
| Execution | ✅ | Core agent roster complete |
| Release | 🟡 | Deployer and post-deploy verification partial |
| Monitor | ❌ | Operations agents not yet designed |
| Optimise | ❌ | Operations agents not yet designed |
| Learning Layer (levels 1–3) | ✅ | Terminal reports + task retro |
| Learning Layer (levels 4–5) | 🟡 | Cycle retro manual; pattern promotion manual |

**MVP delivery path:**
```
Bootstrap → Specification → Execution → Release (partial) → Learning Layer (L1–L3)
```

This is sufficient to run a complete task from specification to
deployment, with full audit trail, independent verification, and
structured learning capture. Discovery and Operations are designed
but deferred to post-MVP.

---

## Track Interaction Rules

These rules govern how work moves between tracks. Violating them
is a topology error.

**Rule 1 — Discovery gates Delivery**
No shaped pitch enters Specification without passing the Shaping gate.
No problem enters Shaping without passing the Problem gate.
(Exception: bug reports from Operations with clear fix scope may
enter Specification directly — they have already been validated by
the live system.)

**Rule 2 — Operations feeds Discovery, not Delivery**
Operations findings do not become tasks directly. They become
Discovery inputs. Discovery decides whether they warrant a shaped
pitch. The only exception is bugs with unambiguous reproduction steps
and contained fix scope (Rule 1 exception).

**Rule 3 — Commitment gates are human**
The transition from Discovery to Delivery (shaped pitch commitment)
and the transition from Release to full production (rollout
authorisation) require human:director explicitly. These are
irreversible resource allocation decisions. (L2)

**Rule 4 — The Learning Layer cannot be skipped**
Every completed task produces a terminal report from every agent.
Every completed Delivery cycle produces a cycle retro. These are
not optional. The audit log records whether terminal reports were
produced. An agent that completes a task without writing a terminal
report has violated T4 (all actions are witnessed). (L3)

**Rule 5 — Track boundaries do not change agent context**
Agents do not know which track they are operating in. They receive
a context card and a task. The track is a governance concept for
humans and the Policy Engine, not a runtime variable available to
agents. (Agent Design Standards, §Two-Layer Model)

---

## Principles Traceability

| Principle | Where it appears in this topology |
|---|---|
| L5 — Problem precedes solution | Problem phase exists and gates Shaping; Shaping gates Delivery |
| L6 — Definition precedes execution | Proof template written in Specification before Execution begins |
| T1 — Verification precedes trust | QA chain in Execution; post-deploy verification in Release |
| T5 — No actor judges own work | ProofDesigner ≠ TaskPerformer; Operations ≠ Discovery for prioritisation |
| PF2 — Validate before you scale | Shaping phase validates approach before Execution commitment |
| PF3 — Lifecycle efficiency | Learning Layer captures full-lifecycle cost; rework tracked as inefficiency |
| L2 — Irreversibility demands presence | Human gates at shaped pitch commitment and production rollout |
| L3 — Knowledge compounds | Learning Layer is a first-class structural element, not optional |
| L4 — Context is local, knowledge is global | Pattern Library is global; context cards are local per task |
| T4 — All actions are witnessed | Terminal reports mandatory; audit log captures all tool calls |

---

## Research Notes — Deferred Design

These are known gaps in the topology. They do not block the MVP but
must be designed before Discovery and Operations tracks can run.

**Discovery agent cluster:**
Problem research, persona development, research synthesis, ideation
(multi-perspective), idea prioritisation, prototyping, user validation.
The de Bono Six Hats model was identified as a candidate for the
ideation phase. Design is pending a dedicated session.

**Operations agent cluster:**
Monitoring, bug capture, triage, feedback routing. These need
integration with production observability tooling (logs, metrics,
error tracking). Design is pending post-MVP.

**Cycle trigger mechanism:**
What starts a new Delivery cycle? Options: appetite-based (enough
shaped pitches exist to fill a declared appetite), time-boxed,
or human:director directive. This decision is deferred pending
first MVP cycle evidence.

**Quorum-based verification:**
T7 (verification is distributable) describes quorum-based reviewer
pools. The MVP uses fixed reviewers per task type. Distributable
verification is a post-MVP upgrade, particularly important for
the DAO use case.

**Cross-project pattern sharing:**
The Pattern Library is project-local in the MVP. Promotion of patterns
to a shared cross-project library (the mechanism for framework-wide
institutional memory) is deferred post-MVP.

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-05 | Initial. Seven phases across three tracks plus Learning Layer. MVP scope declared. Principles traceability table included. |
