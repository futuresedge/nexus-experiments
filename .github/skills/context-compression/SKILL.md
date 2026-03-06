# Skill: Context Compression

TRIGGERS: "curate context", "context card", "compress context",
          "prepare context", "write context card"
PHASE:    Delivery → Specification (SPEC_APPROVED state)
USED BY:  ContextCurator
CONTEXT-TREE NODE: [CONTEXT CURATOR] ★ COMPRESSION NODE


## What this skill does

The compression rubric and conflict detection rules for building
per-agent context cards from source artefacts. This is the only
operation in the framework where input is intentionally larger than
output. The goal is minimum sufficient context for each receiving
agent to do their job — nothing more.

ContextCurator generates multiple independent cards per task.
Each card is compressed independently for its specific receiving
agent and context type. Do not share content between cards by
copying — apply the rubric fresh for each receiving agent.


## Cards to generate per task (standard MVP)

  TaskOrchestrator       context_type: execution
  TaskPerformer          context_type: execution
  QAOrchestrator         context_type: qa
  ProofReviewer          context_type: qa
  ACReviewer             context_type: qa
  EnvironmentReviewer    context_type: qa
  EnvironmentReviewer    context_type: post-deploy  ← different content

All seven cards must pass validation before submit_context_ready.


---


## Part 1 — The Four-Pass Rubric

Apply these passes in sequence to every piece of content before
including it in a card. Stop including when a pass fails.


### Pass 1 — Does this agent need to act on this?

INCLUDE if: the content directly constrains or informs a decision
            this specific agent must make in this task
EXCLUDE if: the content is background, rationale, or history

  INCLUDE: "Build command: pnpm build — must exit with code 0"
  EXCLUDE: "pnpm was chosen over npm for workspace support"

The test is act on — not understand, not find interesting.
Apply this test per receiving agent, not globally. A constraint
relevant to TaskPerformer may be irrelevant to ProofReviewer.


### Pass 2 — Is it already distilled in a document the agent reads?

If the information exists in a more specific form in a document
the agent reads directly — reference the document, do not duplicate.
Duplication creates staleness: if the document changes, the card
is now wrong.

  INCLUDE in TaskPerformer card: task_spec path reference
  EXCLUDE from TaskPerformer card: the full task spec content
                                   (agent reads it directly)

  INCLUDE: proof template criterion summary for ProofReviewer
  EXCLUDE: proof template full text — agent reads it directly

Exception: acceptance criteria goes verbatim into the card (see §3).
The verbatim rule overrides the duplication rule for AC only.


### Pass 3 — Is it verifiable in this task's scope?

INCLUDE if: the agent can act on or verify this within this task alone
EXCLUDE if: verification requires another task to complete first

  EXCLUDE: integration behaviour that depends on a sibling task
  INCLUDE: explicit note that integration behaviour is out of scope

When excluding due to scope: replace with a one-line boundary note.
Do not silently omit — the receiving agent needs to know the boundary
exists, even if the content beyond it does not.


### Pass 4 — Does it conflict with anything already included?

IF conflict detected: do not include either version
Write the conflict to the card's Conflicts and Flags section
See Part 2 (Conflict Detection) for classification and handling

A card with an unresolved Type 1 conflict cannot be submitted.
A card with an unresolved Type 3 conflict can be submitted with
the conflict flagged — TaskPerformer must not proceed until resolved.


---


## Part 2 — Conflict Detection

### Conflict Types

TYPE 1 — Direct contradiction
Two artefacts assert opposite things about the same condition.

  task_spec:             "must not trigger a full page reload"
  environment_contract:  "on save, redirect to /confirmation"
  A redirect IS a full page navigation. These cannot both be true.

TYPE 2 — Scope overlap with divergent constraints
Two artefacts cover the same behaviour with different specifics.
Neither is wrong in kind, but they cannot both be authoritative.

  ac:               "confirmation: 'We'll be in touch within 2 business days'"
  proof_template:   "confirmation: 'Thanks, we'll respond shortly'"

TYPE 3 — Missing dependency
The task spec or AC requires something no source artefact defines.

  ac condition:     "submission event fired to the analytics layer"
  source set:       no definition of analytics layer, event format, or endpoint

TYPE 4 — Stale reference
An artefact references another by path, but that path does not
exist or contains a different version than what is referenced.


### Conflict Handling

TYPE 1:
  DO NOT include either version in the card
  Write to Conflicts and Flags: quote both statements with source
  STOP — do not call submit_context_ready until resolved
  Resolution requires TaskOwner or FeatureOwner decision

TYPE 2:
  Apply authority hierarchy (see below)
  If hierarchy is clear: use authoritative version, note the override
  If hierarchy is unclear: treat as TYPE 1

TYPE 3:
  Write to Conflicts and Flags: name the missing definition,
  which AC condition it blocks, what information is needed
  PROCEED: card can be submitted with the flag present
  DO NOT omit the AC condition that depends on the missing information
  TaskPerformer must not begin work until the gap is resolved

TYPE 4:
  DO NOT include the stale reference
  Write to Conflicts and Flags: name the missing or
  version-mismatched file and which artefact references it
  STOP — do not call submit_context_ready until resolved


### Authority Hierarchy

When two artefacts conflict on the same point, this order
determines which version is authoritative:

  1. task_spec AC section         ← highest — QA reviews against this
  2. task_spec body
  3. proof_template criteria
  4. environment_contract
  5. project_manifest             ← lowest — most likely to be stale
                                     at task scope


### Conflict Record Format

Write to the card's Conflicts and Flags section:

  CONFLICT-[n]
  TYPE:     [1 | 2 | 3 | 4]
  SOURCES:  [artefact-a, section/line] vs [artefact-b, section/line]
  WHAT:     [exact quote or description of each conflicting statement]
  BLOCKS:   [which AC condition or proof criterion this prevents]
  RESOLVE:  [what decision or information resolves it]
  STATUS:   OPEN

Never mark STATUS: RESOLVED on a conflict the curation agent
resolved by judgment. Only an authoritative source (TaskOwner,
FeatureOwner, or human:director) can resolve a conflict.
Resolution must be a document change, not a verbal response.


---


## Part 3 — Per-Agent Inclusion Rules

Apply these rules after the four-pass rubric. They are
agent-specific defaults — the rubric may exclude content
that these rules would include. The rubric wins.


### TaskOrchestrator card
  INCLUDE: task brief (≤ 100 words), task_id, current round number
  INCLUDE: QA tier (determines reviewer activation)
  INCLUDE: dependency list (other tasks that must be DONE first)
  EXCLUDE: proof criteria (TaskOrchestrator routes, does not verify)
  EXCLUDE: full environment contract


### TaskPerformer card
  INCLUDE: task brief, verbatim AC, proof criteria summary (all)
  INCLUDE: build command, test command, local dev port
  INCLUDE: output file path
  INCLUDE: relevant patterns (1–5, PROVISIONAL or ACTIVE only)
  EXCLUDE: full environment contract (only build/test commands needed)
  EXCLUDE: reviewer-scope information


### QAOrchestrator card
  INCLUDE: task brief, QA tier, list of three reviewer agents
  INCLUDE: round number (rework context)
  EXCLUDE: proof criteria (QAOrchestrator reads individual reviews)
  EXCLUDE: environment contract


### ProofReviewer card
  INCLUDE: all proof template criteria (complete, for reference)
  INCLUDE: brief task scope note
  EXCLUDE: environment contract
  EXCLUDE: AC (ProofReviewer checks proof vs template, not proof vs AC)


### ACReviewer card
  INCLUDE: verbatim AC
  INCLUDE: proof criteria that reference AC items
  EXCLUDE: environment contract
  EXCLUDE: proof criteria with no AC reference


### EnvironmentReviewer — context_type: qa
  INCLUDE: full environment contract
  INCLUDE: environment-related proof criteria
  INCLUDE: pre-deploy verification steps
  EXCLUDE: post-deploy health check steps (wrong context)
  BOUNDARIES section must include:
    "Never verify the deployed production URL — staging/local only"


### EnvironmentReviewer — context_type: post-deploy
  INCLUDE: full environment contract
  INCLUDE: post-deploy health check steps
  INCLUDE: production URL
  EXCLUDE: pre-deploy verification steps (wrong context)
  EXCLUDE: proof criteria (post-deploy review uses different evidence)
  BOUNDARIES section must include:
    "Never verify local or staging environment — production URL only"


---


## Part 4 — Token Discipline

BEFORE writing each card: estimate token count of candidate content
TARGET: ≤ 4k tokens per card
IF over budget: apply Pass 1 again — something that seemed
                necessary is not

A card being small is a quality signal, not a risk.
A large card means curation has not been done — it means artefacts
have been concatenated and passed on.

The verbatim AC rule may push a card over budget if AC is long.
In that case: the AC document needs to be revised, not compressed.
Do not summarise or truncate AC to meet a token budget.


---


## What Is Never Included in Any Card

  - project-level context not relevant to this task
  - sibling task files or their context cards
  - agent instruction files or skill content
  - rationale for design decisions (unless it directly constrains
    implementation and no other artefact captures it)
  - content duplicated from a document the agent reads directly
    (exception: verbatim AC)
  - CANDIDATE-status patterns
  - Any artefact not in ContextCurator's READS list for this task
