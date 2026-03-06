# Skill: Agent Design

TRIGGERS: "review agent spec", "evaluate agent", "agent compliance",
          "assess agent file", "write agent spec", "create agent",
          "new agent", "write a spec for", "agent template",
          "spec for zone", "how do I write an agent"
ZONE:     Zone 0 (framework evolution)
USED BY:  TemplateAuthor, AgentSpecReviewer
CONTEXT-TREE NODE: [TEMPLATE AUTHOR], [AGENT SPEC REVIEWER]


## What this skill does

Carries both the writing procedure and the review rubric for agent
spec files (.agent.md). TemplateAuthor uses the Writing Guide below.
AgentSpecReviewer uses the Checklist and Review Result Template below.
The same structural rules govern both operations.


## The Agent Spec Format

Every .agent.md file has two parts: YAML frontmatter and a body.

### YAML Frontmatter (required fields)

  name:         [AgentClassName]              ← PascalCase, matches roster exactly
  description:  [Single sentence job statement — what is this agent hired to do?]
  tools:        ['tool-a', 'tool-b']          ← inline array, not block list
  model:        ['primary-model', 'fallback'] ← inline array, not block list

### Body (required sections, in this order)

  ZONE:             [Phase name — e.g. "Zone 0", "Delivery — Specification"]
  TYPE:             [OWNER | ORCHESTRATOR | EXECUTOR | REVIEWER | BATCH]
  user-invokable:   [true | false]
  QATIER:           [0–4]
  CERTAINTY_THRESHOLD: [0.00–1.00]

  READS:
    - [named file path]     ← named paths only, no categories, no globs

  WRITES:
    - [single artefact path] ← exactly one, not a directory

  NEVER:
    - [prohibited file or artefact path] ← at least one entry, never empty

  SKILL: [skill-name]       ← must resolve to an existing file at declared path

  CONTEXTTREEREF: context-tree.md#[node-name]

  FAILURE MODES:
    - [missing required input scenario]
    - [zero-result search scenario]
    - [at minimum two modes]


## Naming Convention

Agent names are PascalCase class names derived from their job.
They are NOT lowercase hyphenated operational nouns (that was a
previous convention, now superseded).

  "Writes task specs"            → TaskOwner        NOT task-spec-writer
  "Reviews proof templates"      → ProofReviewer    NOT proof-template-reviewer
  "Curates context cards"        → ContextCurator   NOT context-curator
  "Orchestrates task execution"  → TaskOrchestrator NOT task-execution-orchestrator
  "Validates agent specs"        → AgentSpecReviewer NOT agent-spec-reviewer
  "Designs proof templates"      → ProofDesigner    NOT proof-template-designer

Rule: PascalCase, noun-phrase, matches the roster entry exactly.
The roster is the source of truth for all agent class names.


## TYPE Rules

  OWNER         Holds gate authority; user-invokable: true; may use agent tool
  ORCHESTRATOR  Delegates to subagents via agent tool; user-invokable: true
  EXECUTOR      Does work; user-invokable: false; does not use agent tool
  REVIEWER      Verifies work; user-invokable: false; does not use agent tool
  BATCH         Processes collections; user-invokable: false

  user-invokable must be true for OWNER and ORCHESTRATOR.
  user-invokable must be false for EXECUTOR, REVIEWER, and BATCH.
  An EXECUTOR or REVIEWER spec with user-invokable: true fails check B3.


## QATIER Assignment

Score the task on Blast Radius (BR) and Novelty (NV) — see Agent
Creation Policy for full rubric. Assignment:

  NV 3 or BR 4          → Tier 4 (human:director approves)
  NV 2 or BR 3          → Tier 3 (full cycle, human approves at end)
  NV 1 or BR 2          → Tier 2 (full cycle, FrameworkOwner approves)
  NV 0 and BR ≤ 1       → Tier 1 (abbreviated cycle, FOA approves)
  All scores 0          → Tier 0 (stream event only, no review gate)

New agent classes are BR 3 minimum (used repeatedly across the system).


---


## Part A — Writing Guide (TemplateAuthor)

### Required Inputs

Confirm all seven before writing. Raise uncertainty for any that
are missing — one gap at a time, most important first.

  JOB           One sentence: what does this agent produce and for whom?
  ZONE          Which phase does it operate in?
  TYPE          OWNER / ORCHESTRATOR / EXECUTOR / REVIEWER / BATCH?
  READS         Named file paths this agent needs to act (not categories)
  WRITES        Exact output path — one artefact, one path
  SKILL         Which skill file does it load? (must exist at path)
  QATIER        Blast Radius + Novelty score → tier 0–4


### Operation (6 steps — run in order)

  1. Confirm all seven inputs present. Raise uncertainty for gaps.

  2. Derive the agent name from JOB using PascalCase naming convention.
     Check the roster — if a class already exists for this job, do not
     create a duplicate. Raise uncertainty to FrameworkOwner.

  3. Determine TYPE from the job statement:
     - Delegates to other agents?          → ORCHESTRATOR
     - Holds gate/approval authority?      → OWNER
     - Verifies/reviews another's output?  → REVIEWER
     - Performs work, produces artefact?   → EXECUTOR
     - Processes a collection in bulk?     → BATCH

  4. Check context-tree.md for this agent's zone — the node defines
     expected READS, WRITES, NEVER, and CONTEXTTREEREF. Use it as
     a guide; do not invent context tree entries without raising the
     new entry as an uncertainty first.

  5. Run the Pre-Write Checklist below. Fix every failed check before
     writing the file.

  6. Write to .github/agents/[AgentClassName].agent.md.
     Hand off to AgentSpecReviewer. Never self-approve.


### Pre-Write Checklist

YAML Frontmatter:
  [ ] description is a single plain line — no block scalar (| or >)
  [ ] tools is an inline array ['tool-a', 'tool-b']
  [ ] model is an inline array

Body:
  [ ] TYPE declared and correct for the agent's job
  [ ] user-invokable matches TYPE rule
  [ ] QATIER declared and justified by BR+NV scores
  [ ] CERTAINTY_THRESHOLD declared (0.00–1.00)
  [ ] READS declares named file paths only — no categories, no globs
  [ ] Every file in READS exists now — not speculative
  [ ] Every file in READS has a node in context-tree.md OR uncertainty raised
  [ ] WRITES declares exactly one artefact and one path
  [ ] NEVER lists at least one explicit file or artefact path — not empty
  [ ] NEVER includes agent's own WRITES path (cannot review own output)
  [ ] FAILURE MODES covers: missing required input, zero-result search
  [ ] SKILL pointer resolves to an existing file at the declared path
  [ ] CONTEXTTREEREF matches an entry in context-tree.md

Format:
  [ ] Instructions in imperative shorthand — no prose, no "you should"
  [ ] Critical rules appear before SKILL pointer
  [ ] NEVER section is the last section before FAILURE MODES
  [ ] Body is under 60 lines (count non-empty lines, excluding frontmatter)


---


## Part B — Review Checklist (AgentSpecReviewer)

Each check is binary PASS / FAIL. No partial credit.
Source of truth: Agent Design Standards v1.0 and this skill file.


### Section A — YAML Frontmatter

  A1  name present and non-empty string
  A2  description is a single plain line — no block scalar, no newlines
  A3  tools is an inline array ['tool-a', 'tool-b'] — not a block list
  A4  model is an inline array — not a block list


### Section B — Body Structure

  B1  TYPE declared; value is one of the five valid types
  B2  user-invokable matches TYPE rule (OWNER/ORCHESTRATOR true; others false)
  B3  QATIER declared; integer 0–4
  B4  CERTAINTY_THRESHOLD declared; value 0.00–1.00
  B5  READS declares named file paths only — no categories, globs, or dirs
  B6  WRITES declares exactly one artefact — one path, not a directory
  B7  NEVER is non-empty — at least one explicit file or artefact path
  B8  NEVER includes agent's own WRITES path
  B9  FAILURE MODES covers missing required input
  B10 FAILURE MODES covers zero-result search or file lookup returning nothing
  B11 SKILL pointer present — a SKILL: line pointing to a named skill file
  B12 SKILL pointer resolves — the skill file exists at the declared path
  B13 CONTEXTTREEREF present and matches an entry in context-tree.md


### Section C — Instruction Format

  C1  Instructions written as imperative shorthand — no prose, no rationale
  C2  Critical rules appear before the SKILL pointer
  C3  NEVER section appears before FAILURE MODES
  C4  No "you should" / "you must" prose phrasing


### Section D — File-Level Constraints

  D1  Body is under 60 lines (non-empty lines, excluding frontmatter)
  D2  Agent name is PascalCase matching roster entry exactly
  D3  Agent class exists in agent-roster.md (or uncertainty raised to FOA)
  D4  Every READS file has a context-tree.md node or uncertainty on record


### Verdict Criteria

  ACCEPTED
    All checks in A, B, C, D pass.

  ACCEPTED WITH NOTES
    All blocking checks pass. One or more non-blocking checks fail
    or have improvement suggestions.
    Blocking checks: A1–A4, B1–B13, C1, D2, D3.

  RETURNED
    One or more blocking checks fail. List each with specific remediation.


---


## Part C — Review Result Template (AgentSpecReviewer)

Copy exactly. Write to:
  .framework/agent-spec-reviews/[AgentClassName]-review-[YYYY-MM-DD].md

---

  VERDICT:    [ACCEPTED | ACCEPTED WITH NOTES | RETURNED]
  AGENT FILE: .github/agents/[AgentClassName].agent.md
  DATE:       [ISO 8601]
  REVIEWER:   AgentSpecReviewer

  CHECKS PASSED:
    - [A1] name present
    - [B7] NEVER is non-empty
    - ... one line per passing check, citing check ID

  CHECKS FAILED:
    - [B12] SKILL pointer: skill file not found at declared path —
            verify path or register the skill file before resubmitting
    - [C1] Prose instruction on line N: "You should read..." —
            rewrite as imperative shorthand
    - ... one line per failing check with specific, actionable remediation

  NOTES: (ACCEPTED WITH NOTES only — omit section if ACCEPTED or RETURNED)
    - [D1] Body is 63 lines — marginally over target; consolidate
            FAILURE MODES entries

  SECTIONS REVIEWED:
    A — YAML Frontmatter:     [PASS | FAIL]
    B — Body Structure:       [PASS | FAIL]
    C — Instruction Format:   [PASS | FAIL]
    D — File-Level Constraints: [PASS | FAIL]

---


## Bootstrapping Exception

The following eight toolkit agents are hand-built and do not have a
Zone 0 creation record. AgentSpecReviewer must NOT flag them as
non-compliant for this reason. Their specs are valid without a creation
record:

  FrameworkOwner, UncertaintyOwner, ProjectRegistrar,
  EnvironmentContractAuthor, TemplateAuthor, PatternSeeder,
  BootstrapValidator, AgentSpecReviewer

All other agents — including revisions to these eight — must have a
Zone 0 creation record before their spec is considered valid.


## Do Not Load

  - Delivery-phase agent spec files (not in scope for Zone 0 review)
  - Pattern library entries (not relevant to spec structure review)
  - Foundation principles (structural compliance only — principles are
    upstream input, not a checklist item in spec review)
