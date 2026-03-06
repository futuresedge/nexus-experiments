# Naming Conventions

**Version:** 0.1
**Status:** Active
**Principles implemented:** P12
**Last Updated:** 2026-03-04

---

## Purpose

Names in this framework are structural elements, not labels.
They are parsed by the audit log, the webhook handler, the MCP
server, and VS Code. A naming violation is a defect, not a
style preference.

Every identifier family has a format, a reason for that format,
and a spec test. No identifier may deviate from its family's
format without a framework-level decision recorded in the manifest.

---

## 1. Agent Class Names

**Format:** PascalCase. Final component must be a doer word.

```
TaskPerformer     ContextCurator     TemplateAuthor
QAExecutor        SpecValidator      ProofDesigner
TaskOrchestrator  FeatureOwner       UIDesigner
Deployer          ProofReviewer      ACReviewer
```

**Doer word vocabulary:**

| Word | Meaning | Example |
|---|---|---|
| Performer | Executes the primary task work | TaskPerformer |
| Executor | Runs a defined procedure | QAExecutor |
| Curator | Selects, composes, and maintains | ContextCurator |
| Reviewer | Independently verifies output | ProofReviewer |
| Validator | Checks conformance against spec | SpecValidator |
| Author | Writes a composed artefact | TemplateAuthor |
| Designer | Defines what done looks like | ProofDesigner |
| Deployer | Executes delivery to environment | Deployer |
| Orchestrator | Coordinates workflow via subagents | TaskOrchestrator |
| Owner | Holds gate authority over a domain | FeatureOwner |

**Owner exception:**
`Owner` is reserved for agents that hold approval/rejection/halt
authority over a domain. It is not a generic suffix. Every Owner
agent must declare its gate authority in its agent class definition.
Current valid Owner agents: FrameworkOwner, FeatureOwner,
TaskOwner, UncertaintyOwner.

**Prohibited suffixes:**
`Agent`, `Manager`, `Handler`, `Processor`, `Worker` — too generic,
describe a category not an action. Any existing name using these
must be renamed on next revision.

**Spec test:**
- Name is PascalCase with no spaces, hyphens, or underscores
- Final component is in the doer word vocabulary or is `Owner`
- If name does not end in `Orchestrator` or `Owner`,
  `user-invokable` must be `false` in the agent file

---

## 2. Human Actor Identifiers

The human is not an agent but appears as an actor in the audit log.

**Format:** `human:{role}`

```
human:approver     Gate approvals, halt commands, publish decisions
human:director     Framework-level decisions, retro entries,
                   manifest updates made in session
```

**Shorthand:** HA (HumanApprover) in prose and session notes.

**Spec test:**
- Any audit row with `actor_type = 'human'` must use one of
  the declared role values above
- New human role values require a naming conventions update

---

## 3. Entity IDs

**Format:** `{type}-{zero-padded-number}`

```
task-07       feat-003      unc-001
pat-004       kb-012        exp-01
```

**Type prefix vocabulary:**

| Prefix | Entity |
|---|---|
| `task` | Task |
| `feat` | Feature |
| `unc` | Uncertainty |
| `pat` | Pattern Library entry |
| `kb` | Knowledge Base entry |
| `exp` | Experiment |

**Padding rule:** Two digits minimum (`task-07` not `task-7`).
Expand to three digits when count exceeds 99 (`task-100` not
`task-99a`).

**Why hyphens, not underscores:**
Entity IDs appear in branch names, MCP tool suffixes, and URLs.
Underscores are the delimiter in tool names — using underscores
in IDs creates parsing ambiguity when extracting task ID from
`read_task_spec_task_07`. Hyphens produce an unambiguous split.

---

## 4. File Names

**Format:** kebab-case with typed suffix.

**Agent files:**
```
task-performer.agent.md
task-performer-task-07.agent.md    ← instance with task suffix
framework-owner.agent.md
```

**Skill files:**
```
task-performer.skill.md
proof-reviewer.skill.md
context-curator.skill.md
```

**Context card files** (VS Code layer copy):
```
task-performer.context-card.md
task-performer-task-07.context-card.md
```

**Instruction files:**
```
nexus-agent.instructions.md
nexus-startup.instructions.md
```

**Framework document files:**
```
naming-conventions.md
platform-constraints.md
audit-log-schema.md
pattern-library-schema.md
```

**Agent class definition files** (governance, not VS Code layer):
```
task-performer.agent-class.md
framework-owner.agent-class.md
```

**Derivation rule for agent class → file name:**
PascalCase agent class name → kebab-case file name stem.
```
TaskPerformer      → task-performer
ContextCurator     → context-curator
TaskOrchestrator   → task-orchestrator
ProofDesigner      → proof-designer
```

**Spec test:**
- All file names are lowercase
- Word separator is hyphen only — no underscores in file names
- Suffix is always `.{type}.md` for typed files
- No spaces, no uppercase characters

---

## 5. MCP Tool Names

Governed entirely by `.framework/policies/tool-grammar.md`.
This document does not duplicate that specification.

**Cross-reference rule:**
Tool names use underscores as word separators and component
delimiters. This is the only identifier family that uses
underscores — all others use hyphens. This distinction is
intentional and load-bearing: it makes tool names
unambiguously parseable.

---

## 6. Database Identifiers

**Format:** snake_case. Table names are plural nouns.

**Tables:**
```
audit_log          stream_events       documents
tasks              tool_registry       patterns
pattern_evidence   knowledge_base
```

**Column names:**
```
task_id            created_at          doc_version_hash
actor_type         source_audit_id     content_hash
agent_class        entry_hash          result_count
```

**Rules:**
- All lowercase
- Word separator is underscore
- No abbreviations except established ones:
  `id`, `ref`, `hash`, `ac`, `nv`, `br`
- Foreign key columns: `{referenced_table_singular}_id`
  e.g. `pattern_id`, `audit_id`, `task_id`

---

## 7. Branch Names

**Format:** `{type}/{entity-id}`

```
task/task-07          feat/feat-003
framework/exp-02      fix/task-07-auth
```

**Type prefix vocabulary:**

| Prefix | When to use |
|---|---|
| `task/` | Task implementation branch |
| `feat/` | Feature branch (spans multiple tasks) |
| `framework/` | Framework evolution, experiments |
| `fix/` | Hotfix or correction |

**Parsing rule:**
The webhook handler splits on `/` to extract branch type, then
extracts entity ID from the second component. Branch names that
do not follow this format will not be attributed to a task in
the audit log.

---

## 8. Actor Identifiers (Audit Log)

**Format varies by actor type.**

**Agents:**
```
{kebab-agent-class}:{task-id}    task-performer:task-07
{kebab-agent-class}              framework-owner
                                 context-curator
```

Agent class names in the actor field use kebab-case derived
from the PascalCase class name (same derivation rule as file names).

**Humans:**
```
human:approver
human:director
```

**Webhooks:**
```
webhook:github
```

**System:**
```
system:nexus
system:policy-engine
```

**Query pattern:** All actors of a given type share a common
prefix. `WHERE actor LIKE 'human:%'` returns all human actions.
`WHERE actor LIKE 'webhook:%'` returns all external events.
This is load-bearing — do not deviate from the prefix model.

---

## 9. Stream Event Text

Stream events are plain English. No format rules — they are
written for the human reader (HA). One style rule only:

**Past tense, active voice, agent named first.**
```
✅  TaskPerformer submitted proof for task-07.
✅  FrameworkOwner approved publication of feat-003.
✅  UncertaintyOwner blocked task-07 — Redis dependency unresolved.

❌  Proof submitted.
❌  task-07 was blocked by UncertaintyOwner.
❌  The TaskPerformer agent has completed its proof submission.
```

---

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-03-04 | Initial. All seven identifier families defined. |