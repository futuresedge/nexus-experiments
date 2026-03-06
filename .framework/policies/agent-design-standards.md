# Agent Design Standards

**Version:** 1.0
**Status:** Active
**Principles implemented:** P3, P4, P7, P8, P9, P12, P16
**Dependencies:**
  Platform Constraints v1.0
  Tool Grammar v0.3
  Naming Conventions v0.1
  Context Card Schema v1.0
  Pattern Library Schema v1.0
**Last Updated:** 2026-03-04

---

## Purpose

This document defines the rules for designing agents in this framework.
It exists because agent design is not a creative exercise — it is an
engineering discipline with load-bearing constraints. An agent designed
outside these standards will either fail to integrate with the framework,
create audit gaps, or violate the access control model.

Every agent class in this framework must be derived from these standards.
No exceptions without a framework-level decision recorded in the manifest.

---

## The Two-Layer Model

Every agent class exists in two layers simultaneously. Both must be
designed and both must be correct before the agent class is complete.

```
VS CODE LAYER                         NEXUS LAYER
─────────────────────────────         ───────────────────────────────
{agent-class}.agent.md                Agent class definition
  ≤15 lines                             (.framework/agent-classes/)
  Identity + tool list only             Full governance record
  What the agent IS                     Why the agent exists

{agent-class}.skill.md                Context card
  Role knowledge                        Delivered via get_context_card
  How to do the job                     Task-specific knowledge
  Injected by VS Code host              Built by ContextCurator
  No audit entry (H-SKILLS-01)          Full audit entry

{agent-class}.instructions.md         Task-scoped MCP tools
  Always-on rules                       Dynamically assigned
  Hard constraints that                 at task activation
  never change per task
```

**VS Code layer** is static. It defines the agent's identity, capability
vocabulary, and standing knowledge. It never contains task-specific
information.

**Nexus layer** is dynamic. It provides task-specific context (via the
context card) and task-specific capability (via dynamically assigned
task-scoped tools).

An agent file that contains task-specific content is a design violation.
A context card that contains role knowledge (skill content) is a design
violation.

---

## Agent Types

There are four agent types. The type determines the agent's structural
rules, tool allocation, `user-invokable` setting, and naming convention.

| Type | Name suffix | user-invokable | Primary role | Context cap |
|---|---|---|---|---|
| `ORCHESTRATOR` | `*Orchestrator` | `true` | Delegates workflow to subagents | 7 patterns |
| `OWNER` | `*Owner` | `true` | Holds gate authority over a domain | 7 patterns |
| `EXECUTOR` | Any other doer | `false` | Performs a defined task | 3 patterns |
| `REVIEWER` | Any other doer | `false` | Independently verifies output | 3 patterns |

**The naming rule is structural, not cosmetic.** The spec test framework
derives `user-invokable` directly from the agent name. An agent whose
name ends in neither `Orchestrator` nor `Owner` must have
`user-invokable: false`. This is enforced at spec test time, not
by convention.

---

## Type Rules

### ORCHESTRATOR

An Orchestrator coordinates workflow. It delegates to subagents. It
never directly implements task work or reviews task output.

**Structural rules:**
- Must declare an `agents:` list — at minimum two subagents
- Must hold the `agent` tool (enables subagent delegation)
- Must hold all universal tools
- Must NOT hold `write_`, `submit_`, `append_`, or `read_` task
  document tools — it does not perform work, it coordinates it
- May hold `read_` for feature-level documents (feature spec, AC,
  decomposition) to understand scope before delegating
- `user-invokable: true`

**Failure mode to avoid:**
An Orchestrator that directly implements task work defeats the purpose
of the subagent model and contaminates the coordination context with
execution context. If the Orchestrator needs to do work, it means a
subagent class is missing.

### OWNER

An Owner holds gate authority. It approves, rejects, and halts. It
does not coordinate workflow between other agents.

**Structural rules:**
- Must hold `write_` authority for its domain documents
- Must hold `submit_` or `request_` tools for state-transition
  decisions within its authority scope
- Must hold `raise_uncertainty` (all agents do — but especially
  critical here since Owners make irreversible state decisions)
- `user-invokable: true`
- May or may not hold an `agents:` list depending on whether
  authority decisions require subagent validation

**Current Owner agents:**
`FrameworkOwner`, `FeatureOwner`, `TaskOwner`, `UncertaintyOwner`

### EXECUTOR

An Executor performs a defined task. It operates in a clean, narrow
context window. It never coordinates other agents.

**Structural rules:**
- `user-invokable: false` — only receives work via an Orchestrator
  or Owner delegation, or a direct task assignment in the workflow
- Must NOT hold the `agent` tool
- Must NOT hold `write_` tools for documents it submits — if it
  submits a proof, it holds `submit_proof`, not `write_proof`
  (P8: separation of execution and verification applies to
  write authority, not just review)
- Tool list must be the minimum necessary for the defined task
- Context cap: 3 patterns maximum

### REVIEWER

A Reviewer independently verifies output produced by an Executor.
It must be structurally independent — it cannot hold the same write
tools as the Executor it reviews.

**Structural rules:**
- `user-invokable: false`
- Must NOT hold the `agent` tool
- Must NOT hold any `write_`, `append_`, or `submit_` tools for
  documents the Executor it reviews can write — pure read access
  in its domain (P8: separation of execution and verification)
- Must hold `submit_` for its own review document
- Context cap: 3 patterns maximum
- Certainty threshold must be ≥ 0.9 — reviewers must be more
  certain than executors before submitting

---

## Tool Allocation Principles

### Principle 1 — Universal tools belong to every agent

Every agent, without exception, holds:
```
get_context_card
get_my_capabilities
get_current_state
raise_uncertainty
```

There is no agent type for which these are optional. An agent that
cannot load its context card cannot operate. An agent that cannot
raise uncertainty cannot fail safely.

### Principle 2 — Tool possession is capability (P3)

An agent that does not hold a tool cannot call it. This is the
access control model. There is no runtime permission check. There
is no role-based authorisation layer at call time. Access is
determined entirely by what tools the agent was given at design time.

This means tool allocation decisions are security decisions. Giving
an Executor a `write_` tool for a document it should only read is
not a convenience — it is an access control violation.

### Principle 3 — No agent holds both sides of a verification boundary (P8)

For every document that has a submit/review lifecycle:
- The agent that submits it must not be the agent that reviews it
- The agent that reviews it must not hold write access to it

This is structural separation of execution and verification. It is
not enforced by runtime policy — it is enforced by tool design.
If an agent spec violates this principle, the violation is visible
immediately: the agent holds both `submit_proof` and `submit_qa_review`
for the same task document. That is a design defect.

### Principle 4 — Minimum sufficient tools (P7)

The tool list for any agent is the minimum set of tools the agent
needs to complete its defined task. Not the minimum possible (which
would prevent the agent operating). Not all available tools (which
would violate P3 and P8). Minimum sufficient.

When in doubt, omit the tool. An agent that lacks a needed tool will
call `raise_uncertainty` (P9). That is the correct behaviour. An
agent that has an unnecessary tool may use it inappropriately and
produce an untraceable side effect.

### Principle 5 — Task-scoped tools are assigned dynamically

An Executor does not permanently hold `read_task_spec_task_07`. That
tool is assigned when task-07 is activated and revoked when task-07
is closed. The agent class definition lists the tool *types* the
agent will receive (e.g. `read_task_spec_{task_id}`) — the actual
tools are dynamically registered by the Nexus server.

This means the agent file's `tools:` list contains:
- All universal tools (always static)
- All role-scoped tools (static)
- A notation for dynamically assigned task-scoped tools (not listed
  individually — they are described in the agent class definition)

---

## The Agent File

The agent file is the VS Code artefact. It is the agent's identity
card in the VS Code layer.

**Hard constraints:**
- Maximum 15 lines of content (excluding YAML frontmatter delimiter
  lines `---`)
- Instructions are 2–4 lines maximum
- No task-specific content
- No policy references
- No governance metadata
- No file paths

**What belongs in the agent file:**
- `name` — PascalCase, from naming conventions
- `description` — one sentence, active voice, what the agent does
- `model` — model identifier
- `user-invokable` — derived from agent type
- `tools` — universal + role-scoped tools only
- `agents` — for Orchestrators only
- Instructions: "Call `get_context_card` to load your brief. [One
  sentence primary directive.] Call `raise_uncertainty` if blocked."

**What does not belong in the agent file:**
Everything else. The agent file is not documentation. It is not a
specification. It is not a training document. It is a minimal
identity declaration. Governance information lives in the agent
class definition. Task information lives in the context card.
Role knowledge lives in the skill file.

---

## The Skill File

The skill file is the agent's role knowledge. It defines how the
agent does its job — craft knowledge, output format standards,
quality criteria, decision frameworks.

**Delivered by:** VS Code host layer at agent instantiation.
No read tool required. No audit entry produced. (H-SKILLS-01,
confirmed 2026-03-04)

**What belongs in the skill file:**
- How to structure outputs for this agent's role
- Quality criteria that apply to every task of this type
- Decision frameworks for common judgment calls
- Output format templates and examples
- What good looks like; what failure looks like

**What does not belong in the skill file:**
- Task-specific information (belongs in context card)
- Policy references (belongs in constraints, delivered via card)
- File paths (agent doesn't need to know where things live)
- Audit or governance instructions (handled by tool design)

**Naming:** `{agent-class}.skill.md` in `.github/skills/`

The skill file is referenced in the agent class definition.
It is not referenced in the agent file directly — VS Code discovers
it through the agent configuration mechanism.

---

## The Agent Class Definition

The agent class definition is the governance artefact. It lives in
`.framework/agent-classes/` and is never delivered to the agent.
It is the source of truth for the ContextCurator when building
context cards, and for the FrameworkOwner when auditing agent design.

**Contents:**
- Agent type (ORCHESTRATOR / OWNER / EXECUTOR / REVIEWER)
- Purpose statement (2–3 sentences — what problem does this agent
  class solve, why does it exist as a separate class)
- Certainty threshold (0.0–1.0)
- Canonical tool list with justification for each tool
- Skill file reference
- Pattern tags (which domain tags should be searched when building
  this agent's context cards)
- Gate authority declaration (for OWNER type only)
- Subagent list with delegation protocol (for ORCHESTRATOR type only)

See `.framework/templates/agent-class-definition-template.md`

---

## Process: Designing a New Agent Class

Apply in order. Do not skip steps.

**Step 1 — Identify the gap**
What task is currently not being done, or being done by an agent
that is accumulating too much context? The answer must be a concrete
task with a defined output, not a vague capability.

**Step 2 — Determine the type**
Does this agent coordinate, own, execute, or review?
- If it delegates work to others → ORCHESTRATOR
- If it approves/rejects/halts work → OWNER
- If it produces a defined output → EXECUTOR
- If it verifies a defined output → REVIEWER

If the answer is "both execute and review" → it is two agents.
Separation of execution and verification is non-negotiable (P8).

**Step 3 — Name it**
Apply naming conventions. Final component must be from the doer
word vocabulary, or `Owner` for gate authority agents. If you
cannot name it with a doer word, the type is probably wrong.

**Step 4 — Define the tool list**
Start with universal tools (all agents). Add role-scoped tools.
Note task-scoped tools that will be dynamically assigned.
For each tool, write one sentence: why does this agent need this tool?
If you cannot answer, remove the tool.
Apply P8 check: does this agent hold both sides of any
verification boundary? If yes, redesign.

**Step 5 — Write the skill file**
What does this agent need to know to do its job well, regardless
of which specific task it is working on? Write that. Keep it to
what an expert practitioner would consider role knowledge vs
task briefing.

**Step 6 — Write the agent class definition**
Fill the template. This is the governance record. It must be
complete before the agent file is written — the agent file is
derived from the class definition, not the other way around.

**Step 7 — Write the agent file**
Derive from the class definition. Apply the 15-line constraint.
Write 2–4 lines of instructions. Confirm that the file contains
no task-specific content, no policy references, no file paths.

**Step 8 — Run spec tests**
See Spec Tests section. All tests must pass before the agent class
is considered complete.

**Step 9 — Register in the framework manifest**
Record the new agent class as a Named Addition. Include the
derivation decision and any design choices made in Steps 2–4.

---

## Spec Tests

These tests apply to every agent class in the framework. Run
before declaring an agent class design complete.

**Naming and Type:**
```
T-01  Name is PascalCase with no spaces, hyphens, or underscores
T-02  Final name component is in the doer word vocabulary or is 'Owner'
T-03  If name ends in 'Orchestrator' or 'Owner': user-invokable is true
T-04  If name does NOT end in 'Orchestrator' or 'Owner':
        user-invokable is false or absent (defaults to false)
```

**Agent File:**
```
T-05  Agent file content is ≤15 lines (excluding --- delimiters)
T-06  Agent file contains no file paths
T-07  Agent file contains no policy references
T-08  Agent file instructions are ≤4 lines
T-09  Agent file instructions include get_context_card call
T-10  Agent file instructions include raise_uncertainty reference
T-11  Agent file contains no task-specific content
```

**Tool Allocation:**
```
T-12  Agent holds all four universal tools:
        get_context_card, get_my_capabilities,
        get_current_state, raise_uncertainty
T-13  EXECUTOR and REVIEWER agents do not hold the 'agent' tool
T-14  ORCHESTRATOR agents declare an 'agents:' list with ≥2 entries
T-15  No agent holds both submit_{doc} and submit_qa_review_{doc}
        for the same document (P8 — execution/verification separation)
T-16  No REVIEWER agent holds write_, append_, or submit_ tools
        for documents produced by the Executor it reviews
T-17  For each tool in the list: a one-sentence justification
        exists in the agent class definition
```

**Skill File:**
```
T-18  Skill file exists at .github/skills/{agent-class}.skill.md
T-19  Skill file contains no task-specific content
T-20  Skill file contains no file paths
T-21  Skill file contains no policy document references
T-22  Skill file reference exists in the agent class definition
        NOTE: VS Code delivers this — no read tool required or permitted.
        A read_ tool for a skill file is an automatic T-16 violation.
```

**Agent Class Definition:**
```
T-23  Agent class definition exists at
        .framework/agent-classes/{agent-class}.agent-class.md
T-24  Agent type is declared and valid
        (ORCHESTRATOR | OWNER | EXECUTOR | REVIEWER)
T-25  Certainty threshold is declared (0.0–1.0)
T-26  REVIEWER agent certainty threshold is ≥ 0.9
T-27  OWNER agent declares gate authority scope
T-28  Pattern tags are declared (≥1 tag required)
T-29  Agent class is registered in the framework manifest
```

---

## Known Agent Classes

| Agent Class | Type | user-invokable | Status |
|---|---|---|---|
| `FrameworkOwner` | OWNER | ✅ | Defined |
| `FeatureOwner` | OWNER | ✅ | Defined |
| `TaskOwner` | OWNER | ✅ | Defined |
| `UncertaintyOwner` | OWNER | ✅ | Defined |
| `TaskOrchestrator` | ORCHESTRATOR | ✅ | To be designed |
| `DeliveryOrchestrator` | ORCHESTRATOR | ✅ | To be designed |
| `ContextCurator` | EXECUTOR | ❌ | To be designed |
| `TaskPerformer` | EXECUTOR | ❌ | To be designed |
| `QAExecutor` | EXECUTOR | ❌ | To be designed |
| `TemplateAuthor` | EXECUTOR | ❌ | To be designed |
| `SpecValidator` | EXECUTOR | ❌ | To be designed |
| `ProofDesigner` | EXECUTOR | ❌ | To be designed |
| `UIDesigner` | EXECUTOR | ❌ | To be designed |
| `Deployer` | EXECUTOR | ❌ | To be designed |
| `ProofReviewer` | REVIEWER | ❌ | To be designed |
| `ACReviewer` | REVIEWER | ❌ | To be designed |
| `EnvironmentReviewer` | REVIEWER | ❌ | To be designed |

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-03-04 | Initial. Two-layer model formalised. Four agent types defined. 29 spec tests established. Known agent class roster recorded. |
