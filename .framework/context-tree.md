# Context Tree

**Version:** 1.0
**Status:** Active
**Dependencies:**
  Agent Roster v0.2
  Lifecycle Architecture v1.0
  Agent Design Standards v1.0
**Last Updated:** 2026-03-05

---

## Purpose

This document is the authoritative registry of every artefact in the
Nexus Framework and every agent node in the workflow. It serves two
functions:

1. **Artefact registry** — every file that any agent reads or writes
   is declared here. AgentSpecReviewer validates that every path in
   an agent's READS list has a node in this document.

2. **Agent node index** — every agent class has a node here that is
   the target of its CONTEXTTREEREF declaration.

This document does not explain the framework. It records structure.

---

## Node Format Reference

### Artefact Node

  NODE: [node-name]             ← anchor target for READS validation
  PATH: [path]                  ← exact path; {variables} for parametric
  WRITE MODE: [mode]            ← Create-once | Replace | Append
  WRITTEN BY: [agent class]     ← one agent class only
  READY WHEN: [state]           ← lifecycle state when valid to read
  READ BY: [agent classes]      ← comma-separated; ALL = universal read

### Agent Node

  AGENT NODE: [node-name]       ← anchor target for CONTEXTTREEREF
  AGENT CLASS: [AgentClass]
  PHASE: [phase name]
  ACTIVATES ON: [state or event]

---

## Section 1 — Framework Policies (Read-Only Toolkit)

These files are part of the toolkit. They are written once by
human:director and FrameworkOwner during framework authoring.
No delivery agent writes to these files. No agent has them in WRITES.

---

  NODE: framework-policies-foundation
  PATH: .framework/policies/foundation-principles.md
  WRITE MODE: Replace (FrameworkOwner only, framework evolution)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always (toolkit artefact)
  READ BY: ALL

---

  NODE: framework-policies-topology
  PATH: .framework/policies/work-topology.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: ALL

---

  NODE: framework-policies-lifecycle
  PATH: .framework/policies/lifecycle-architecture.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: ALL

---

  NODE: framework-policies-tool-grammar
  PATH: .framework/policies/tool-grammar.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: ALL

---

  NODE: framework-policies-agent-design
  PATH: .framework/policies/agent-design-standards.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: TemplateAuthor, AgentSpecReviewer, FrameworkOwner

---

  NODE: framework-policies-agent-creation
  PATH: .framework/policies/agent-creation-policy.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: FrameworkOwner, TemplateAuthor, AgentSpecReviewer

---

  NODE: framework-base-agent-template
  PATH: .framework/agent-classes/base-agent-template.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: TemplateAuthor, AgentSpecReviewer

---

  NODE: framework-agent-roster
  PATH: .framework/agent-classes/agent-roster.md
  WRITE MODE: Replace (FrameworkOwner only)
  WRITTEN BY: FrameworkOwner
  READY WHEN: always
  READ BY: ALL

---

## Section 2 — Zone 0: Bootstrap Artefacts

---

  NODE: z0-project-manifest
  PATH: .framework/project-manifest.md
  WRITE MODE: Replace
  WRITTEN BY: ProjectRegistrar
  READY WHEN: human:director approves (status: APPROVED)
  READ BY: ALL — this is the root reference document for the project
  NOTE: One per project. human:director approval is the gate.
        Status field must be APPROVED before any agent may depend on it.

---

  NODE: z0-environment-contract
  PATH: .framework/environment-contract.md
  WRITE MODE: Replace
  WRITTEN BY: EnvironmentContractAuthor
  READY WHEN: EnvironmentReviewer returns PASS (Z0-2 gate)
  READ BY: TaskOwner, TaskPerformer, EnvironmentReviewer,
           ContextCurator, BootstrapValidator, Deployer,
           DeliveryOrchestrator, EnvironmentContractAuthor

---

  NODE: z0-bootstrap-report
  PATH: .framework/bootstrap-report.md
  WRITE MODE: Create-once
  WRITTEN BY: BootstrapValidator
  READY WHEN: written (human:director reviews to approve)
  READ BY: FrameworkOwner, human:director

---

  NODE: z0-agent-spec-review
  PATH: .framework/agent-spec-reviews/{AgentClass}-review-{date}.md
  WRITE MODE: Create-once
  WRITTEN BY: AgentSpecReviewer
  READY WHEN: written
  READ BY: FrameworkOwner, TemplateAuthor

---

## Section 3 — Agent Files

---

  NODE: agent-file
  PATH: .github/agents/{AgentClass}.agent.md
  WRITE MODE: Replace
  WRITTEN BY: TemplateAuthor
  READY WHEN: AgentSpecReviewer returns ACCEPTED or ACCEPTED WITH NOTES
  READ BY: AgentSpecReviewer, FrameworkOwner, BootstrapValidator

---

## Section 4 — Pattern Library

---

  NODE: pattern-entry
  PATH: .framework/patterns/{pattern-id}.pattern.md
  WRITE MODE: Create-once (CANDIDATE); Replace (status updates only)
  WRITTEN BY: PatternSeeder (CANDIDATE), FrameworkOwner (promotes status)
  READY WHEN: status is PROVISIONAL or ACTIVE
  READ BY: ContextCurator, FrameworkOwner, TaskOrchestrator,
           TaskPerformer (via search_knowledge_base)
  NOTE: CANDIDATE patterns are not surfaced in context cards.
        ContextCurator must check status before referencing.

---

## Section 5 — Agent Class Definitions

---

  NODE: agent-class-definition
  PATH: .framework/agent-classes/{AgentClass}.agent-class.md
  WRITE MODE: Replace
  WRITTEN BY: FrameworkOwner
  READY WHEN: FrameworkOwner approves
  READ BY: TemplateAuthor, AgentSpecReviewer, FrameworkOwner

---

## Section 6 — Skill Files

---

  NODE: skill-file
  PATH: .skills/{skill-name}.skill.md
  WRITE MODE: Replace
  WRITTEN BY: FrameworkOwner (or TemplateAuthor under FrameworkOwner direction)
  READY WHEN: always (toolkit artefacts — must exist before agents that
              reference them are written)
  READ BY: any agent whose SKILL pointer references this path
  NOTE: A skill file that does not exist at its declared path is a
        failing check B12 in AgentSpecReviewer's checklist.

---

## Section 7 — Pitch and Feature Artefacts

Path root: .framework/features/{feature}/

---

  NODE: feature-spec
  PATH: .framework/features/{feature}/feature-spec.md
  WRITE MODE: Replace
  WRITTEN BY: FeatureOwner
  READY WHEN: FeatureOwner submits (status: SUBMITTED)
  READ BY: FeatureOwner, TaskOwner, ACReviewer, ContextCurator,
           ProofDesigner

---

  NODE: feature-ac
  PATH: .framework/features/{feature}/ac.md
  WRITE MODE: Replace
  WRITTEN BY: FeatureOwner
  READY WHEN: human:director approves (status: APPROVED)
  READ BY: FeatureOwner, TaskOwner, ProofDesigner, ACReviewer,
           ContextCurator
  NOTE: Verbatim inclusion required in context cards.
        ContextCurator never paraphrases this document.

---

  NODE: feature-pitch
  PATH: .framework/features/{feature}/pitch.md
  WRITE MODE: Replace
  WRITTEN BY: FeatureOwner
  READY WHEN: human:director commits (pitch status: COMMITTED)
  READ BY: TaskOwner, FrameworkOwner

---

## Section 8 — Task: Specification Phase Artefacts

Path root: .framework/features/{feature}/tasks/{task}/

---

  NODE: task-spec
  PATH: .framework/features/{feature}/tasks/{task}/task-spec.md
  WRITE MODE: Replace
  WRITTEN BY: TaskOwner
  READY WHEN: task state: SPEC_APPROVED
  READ BY: TaskOwner, ProofDesigner, ContextCurator, TaskOrchestrator,
           TaskPerformer, FrameworkOwner, BootstrapValidator (smoke test)
  NOTE: QA tier must be set in this document. ProofDesigner must not
        write the proof template before this document is SPEC_APPROVED.

---

  NODE: task-proof-template
  PATH: .framework/features/{feature}/tasks/{task}/proof-template.md
  WRITE MODE: Create-once
  WRITTEN BY: ProofDesigner
  READY WHEN: task state: SPEC_APPROVED (written concurrently with task-spec)
  READ BY: TaskOwner, ContextCurator, TaskPerformer, ProofReviewer,
           ACReviewer, QAOrchestrator, FrameworkOwner
  NOTE: ProofDesigner must never be the same agent instance as
        TaskPerformer for this task. Enforced by Policy Engine PE-01.

---

  NODE: task-context-card
  PATH: .framework/features/{feature}/tasks/{task}/context-cards/
        {AgentClass}-{context-type}.md
  WRITE MODE: Create-once
  WRITTEN BY: ContextCurator
  READY WHEN: task state: CONTEXT_READY
  READ BY: the specific {AgentClass} named in the path
  NOTE: Each card is readable only by its named agent class.
        ContextCurator generates 7 cards per standard MVP task.
        context-type values: execution | qa | post-deploy | zone-0

---

## Section 9 — Task: Execution Phase Artefacts

---

  NODE: task-work-log
  PATH: .framework/features/{feature}/tasks/{task}/work-log.md
  WRITE MODE: Append
  WRITTEN BY: TaskPerformer, Deployer (separate phases)
  READY WHEN: task state: IN_PROGRESS (created on first append)
  READ BY: TaskOrchestrator, QAOrchestrator, FrameworkOwner,
           DeliveryOrchestrator

---

  NODE: task-proof
  PATH: .framework/features/{feature}/tasks/{task}/proof.md
  WRITE MODE: Replace (each rework round replaces previous proof)
  WRITTEN BY: TaskPerformer
  READY WHEN: task state: SUBMITTED
  READ BY: ProofReviewer, ACReviewer, EnvironmentReviewer,
           QAOrchestrator, TaskOrchestrator, human:approver
  NOTE: Each round replaces the previous proof.
        Round number recorded in document header and audit log.

---

  NODE: task-uncertainty-log
  PATH: .framework/features/{feature}/tasks/{task}/uncertainty-log.md
  WRITE MODE: Append
  WRITTEN BY: UncertaintyOwner
  READY WHEN: created on first uncertainty raised
  READ BY: UncertaintyOwner, TaskOwner, FrameworkOwner,
           human:director, ContextCurator (conflict detection)
  NOTE: Never modified retroactively. Entries are append-only.
        STATUS field on each entry is updated in-place (OPEN → RESOLVED).

---

## Section 10 — Task: QA Phase Artefacts

---

  NODE: task-proof-review
  PATH: .framework/features/{feature}/tasks/{task}/reviews/proof-review.md
  WRITE MODE: Create-once per round
  WRITTEN BY: ProofReviewer
  READY WHEN: task state: QA_IN_PROGRESS
  READ BY: QAOrchestrator, TaskOrchestrator, TaskPerformer (rework)
  NOTE: Filename convention: proof-review-r{N}.md where N is round number.

---

  NODE: task-ac-review
  PATH: .framework/features/{feature}/tasks/{task}/reviews/ac-review.md
  WRITE MODE: Create-once per round
  WRITTEN BY: ACReviewer
  READY WHEN: task state: QA_IN_PROGRESS
  READ BY: QAOrchestrator, TaskOrchestrator, TaskPerformer (rework)
  NOTE: Filename convention: ac-review-r{N}.md

---

  NODE: task-env-review-qa
  PATH: .framework/features/{feature}/tasks/{task}/reviews/
        env-review-qa.md
  WRITE MODE: Create-once per round
  WRITTEN BY: EnvironmentReviewer (context_type: qa)
  READY WHEN: task state: QA_IN_PROGRESS
  READ BY: QAOrchestrator, TaskOrchestrator, TaskPerformer (rework)
  NOTE: Filename convention: env-review-qa-r{N}.md

---

  NODE: task-qa-review
  PATH: .framework/features/{feature}/tasks/{task}/reviews/qa-review.md
  WRITE MODE: Create-once per round
  WRITTEN BY: QAOrchestrator
  READY WHEN: task state: QA_PASSED or QA_FAILED
  READ BY: TaskOrchestrator, TaskPerformer (rework), human:approver,
           FrameworkOwner
  NOTE: Filename convention: qa-review-r{N}.md
        This is the synthesised verdict document — the human:approver
        reads this, not the individual reviewer documents.

---

## Section 11 — Task: Release Phase Artefacts

---

  NODE: task-env-review-postdeploy
  PATH: .framework/features/{feature}/tasks/{task}/reviews/
        env-review-postdeploy.md
  WRITE MODE: Create-once
  WRITTEN BY: EnvironmentReviewer (context_type: post-deploy)
  READY WHEN: task state: DEPLOYING (post-deployment)
  READ BY: DeliveryOrchestrator, FrameworkOwner

---

## Section 12 — Learning Layer Artefacts

---

  NODE: task-terminal-report
  PATH: .framework/features/{feature}/tasks/{task}/
        terminal-reports/{AgentClass}-terminal-report.md
  WRITE MODE: Create-once
  WRITTEN BY: the {AgentClass} named in the path
  READY WHEN: task reaches terminal state (DONE, REJECTED, or CANCELLED)
  READ BY: TaskOrchestrator, FrameworkOwner
  NOTE: Required from every agent that was active on the task.
        Policy Engine PE-07 blocks final tool revocation until
        all expected terminal reports exist.

---

  NODE: task-retro
  PATH: .framework/features/{feature}/tasks/{task}/task-retro.md
  WRITE MODE: Create-once
  WRITTEN BY: TaskOrchestrator
  READY WHEN: all terminal reports received for this task
  READ BY: FrameworkOwner
  NOTE: Aggregate of all terminal reports for this task.

---

  NODE: cycle-retro
  PATH: .framework/cycles/{cycle}/cycle-retro.md
  WRITE MODE: Create-once
  WRITTEN BY: FrameworkOwner
  READY WHEN: cycle state: RETRO_IN_PROGRESS
  READ BY: FrameworkOwner, human:director

---

## Section 13 — Agent Nodes (CONTEXTTREEREF Targets)

These are the anchor targets for each agent class's CONTEXTTREEREF
declaration. They record where in the workflow the agent operates.
They are not artefact nodes — they don't represent files.

---

  AGENT NODE: agent-FrameworkOwner
  AGENT CLASS: FrameworkOwner
  PHASE: Zone 0 — all phases (cross-cutting governance)
  ACTIVATES ON: framework evolution events; cycle COMPLETE; Zone 0 tasks

  AGENT NODE: agent-UncertaintyOwner
  AGENT CLASS: UncertaintyOwner
  PHASE: Cross-cutting — all phases
  ACTIVATES ON: raise_uncertainty called by any agent

  AGENT NODE: agent-ProjectRegistrar
  AGENT CLASS: ProjectRegistrar
  PHASE: Zone 0 — Task Z0-1
  ACTIVATES ON: Zone 0 initiated by human:director

  AGENT NODE: agent-EnvironmentContractAuthor
  AGENT CLASS: EnvironmentContractAuthor
  PHASE: Zone 0 — Task Z0-2
  ACTIVATES ON: project-manifest.md status: APPROVED

  AGENT NODE: agent-TemplateAuthor
  AGENT CLASS: TemplateAuthor
  PHASE: Zone 0 — Task Z0-3
  ACTIVATES ON: FrameworkOwner activates for each agent class in roster

  AGENT NODE: agent-PatternSeeder
  AGENT CLASS: PatternSeeder
  PHASE: Zone 0 — Task Z0-4
  ACTIVATES ON: environment-contract.md status: APPROVED (Z0-2 gate passed)

  AGENT NODE: agent-BootstrapValidator
  AGENT CLASS: BootstrapValidator
  PHASE: Zone 0 — Task Z0-5
  ACTIVATES ON: all Z0-1 through Z0-4 gates passed

  AGENT NODE: agent-AgentSpecReviewer
  AGENT CLASS: AgentSpecReviewer
  PHASE: Zone 0 — Task Z0-3 (and ongoing for new agents)
  ACTIVATES ON: TemplateAuthor submits agent file

  AGENT NODE: agent-FeatureOwner
  AGENT CLASS: FeatureOwner
  PHASE: Discovery → Shaping
  ACTIVATES ON: human:director initiates feature definition

  AGENT NODE: agent-TaskOwner
  AGENT CLASS: TaskOwner
  PHASE: Delivery — Specification (DRAFT state)
  ACTIVATES ON: pitch status: COMMITTED

  AGENT NODE: agent-ProofDesigner
  AGENT CLASS: ProofDesigner
  PHASE: Delivery — Specification (DRAFT state, concurrent with TaskOwner)
  ACTIVATES ON: TaskOwner activates via agent tool after task spec draft

  AGENT NODE: agent-ContextCurator
  AGENT CLASS: ContextCurator
  PHASE: Delivery — Specification (SPEC_APPROVED state)
  ACTIVATES ON: task state: SPEC_APPROVED

  AGENT NODE: agent-TaskOrchestrator
  AGENT CLASS: TaskOrchestrator
  PHASE: Delivery — Execution (IN_PROGRESS through QA_PASSED)
  ACTIVATES ON: task state: CONTEXT_READY (Policy Engine PE-10)

  AGENT NODE: agent-TaskPerformer
  AGENT CLASS: TaskPerformer
  PHASE: Delivery — Execution (IN_PROGRESS state)
  ACTIVATES ON: TaskOrchestrator activates via agent tool

  AGENT NODE: agent-QAOrchestrator
  AGENT CLASS: QAOrchestrator
  PHASE: Delivery — Execution (QA_IN_PROGRESS state)
  ACTIVATES ON: task state: SUBMITTED (Policy Engine PE-11)

  AGENT NODE: agent-ProofReviewer
  AGENT CLASS: ProofReviewer
  PHASE: Delivery — Execution (QA_IN_PROGRESS state)
  ACTIVATES ON: QAOrchestrator activates via agent tool

  AGENT NODE: agent-ACReviewer
  AGENT CLASS: ACReviewer
  PHASE: Delivery — Execution (QA_IN_PROGRESS state)
  ACTIVATES ON: QAOrchestrator activates via agent tool (parallel)

  AGENT NODE: agent-EnvironmentReviewer
  AGENT CLASS: EnvironmentReviewer
  PHASE: Delivery — Execution (QA) + Release (post-deploy)
  ACTIVATES ON: QAOrchestrator activates (qa context);
                DeliveryOrchestrator activates (post-deploy context)

  AGENT NODE: agent-DeliveryOrchestrator
  AGENT CLASS: DeliveryOrchestrator
  PHASE: Delivery — Release (APPROVED through DONE)
  ACTIVATES ON: task state: APPROVED (Policy Engine PE-13)

  AGENT NODE: agent-Deployer
  AGENT CLASS: Deployer
  PHASE: Delivery — Release (DEPLOYING state)
  ACTIVATES ON: DeliveryOrchestrator activates via agent tool

---

## Section 14 — READS Validation Quick Reference

When AgentSpecReviewer validates a READS declaration, every path
must resolve to a node in this document. Use this index:

  .framework/policies/*.md              → Section 1
  .framework/project-manifest.md        → Section 2, z0-project-manifest
  .framework/environment-contract.md    → Section 2, z0-environment-contract
  .framework/bootstrap-report.md        → Section 2, z0-bootstrap-report
  .framework/agent-spec-reviews/*.md    → Section 2, z0-agent-spec-review
  .github/agents/*.agent.md             → Section 3, agent-file
  .framework/patterns/*.pattern.md      → Section 4, pattern-entry
  .framework/agent-classes/*.md         → Section 5, agent-class-definition
  .skills/*.skill.md                    → Section 6, skill-file
  .framework/features/{f}/feature-spec.md → Section 7, feature-spec
  .framework/features/{f}/ac.md           → Section 7, feature-ac
  .framework/features/{f}/pitch.md        → Section 7, feature-pitch
  .framework/features/{f}/tasks/{t}/task-spec.md       → Section 8
  .framework/features/{f}/tasks/{t}/proof-template.md  → Section 8
  .framework/features/{f}/tasks/{t}/context-cards/*.md → Section 8
  .framework/features/{f}/tasks/{t}/work-log.md        → Section 9
  .framework/features/{f}/tasks/{t}/proof.md           → Section 9
  .framework/features/{f}/tasks/{t}/uncertainty-log.md → Section 9
  .framework/features/{f}/tasks/{t}/reviews/*.md       → Sections 10–11
  .framework/features/{f}/tasks/{t}/terminal-reports/  → Section 12
  .framework/features/{f}/tasks/{t}/task-retro.md      → Section 12
  .framework/cycles/{c}/cycle-retro.md                 → Section 12

  ANY PATH NOT IN THIS LIST → failing check D4 in AgentSpecReviewer rubric.
  Raise uncertainty to FrameworkOwner — either the node is missing from
  this document, or the READS declaration references a non-existent file.

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-05 | Initial version. Full rewrite from prior zone-numbered model. 14 sections, 40+ artefact nodes, 20 agent nodes. |
