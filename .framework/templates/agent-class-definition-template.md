# Agent Class Definition — {AgentClassName}

**Agent Class:** {AgentClassName}
**Agent Type:** {ORCHESTRATOR | OWNER | EXECUTOR | REVIEWER}
**Kebab ID:** {agent-class-name}
**Version:** 1.0
**Status:** {DRAFT | ACTIVE | DEPRECATED}
**Created:** {YYYY-MM-DD}
**Last Updated:** {YYYY-MM-DD}

---

## Purpose

<!-- 2–3 sentences. What problem does this agent class solve?
     Why does it exist as a separate class rather than being
     part of an existing class? -->

---

## Agent Type Justification

<!-- One sentence: why is this type correct for this class?
     "This agent is a REVIEWER because it independently verifies
     [X] and must not hold write access to documents it reviews." -->

---

## Certainty Threshold

**Value:** {0.0–1.0}

<!-- Justify the threshold. Why is this the right level for this
     agent's decisions? REVIEWER agents must be ≥ 0.9. -->

---

## Gate Authority
<!-- OWNER agents only. Delete this section for other types. -->

**Domain:** {What this Owner has authority over}
**Can approve:** {list}
**Can reject:** {list}
**Can halt:** {list}
**Cannot:** {explicit scope limits}

---

## Subagent Delegation Protocol
<!-- ORCHESTRATOR agents only. Delete this section for other types. -->

**Delegates to:**

| Subagent | When | Expected output |
|---|---|---|
| {SubagentName} | {condition} | {output format} |

**Delegation rules:**
<!-- How does this Orchestrator decide what to delegate, in what
     order, and how does it synthesise results? -->

---

## Tool List

### Universal Tools (all agents)
| Tool | Justification |
|---|---|
| `get_context_card` | Load task brief at instantiation |
| `get_my_capabilities` | Inspect own registered tool list |
| `get_current_state` | Check task lifecycle state |
| `raise_uncertainty` | Signal blocked or uncertain state to human |

### Role-Scoped Tools
| Tool | Justification |
|---|---|
| {tool_name} | {one sentence — why does this agent need this tool?} |

### Task-Scoped Tools (dynamically assigned at task activation)
| Tool pattern | Justification |
|---|---|
| `{verb}_{subject}_{task_id}` | {one sentence} |

### Orchestrator Tools
<!-- ORCHESTRATOR and OWNER agents only. Delete for EXECUTOR/REVIEWER. -->
| Tool | Justification |
|---|---|
| `agent` | Delegate work to subagents |

---

## P8 Verification Check

<!-- For each document in this agent's write scope, confirm that
     no other tool in this list allows this agent to verify its
     own output. -->

| Document | This agent writes via | Reviews are done by |
|---|---|---|
| {document_type} | {tool_name} | {ReviewerAgentClass} |

**Conflicts:** {None | describe any identified conflict}

---

## Skill File

**Path:** `.github/skills/{agent-class}.skill.md`
**Covers:**
- {bullet list of what role knowledge the skill file contains}

---

## Pattern Tags

<!-- Tags used by ContextCurator to select relevant patterns
     for this agent's context cards. -->

**Primary tags:** {tag-1}, {tag-2}
**Secondary tags:** {tag-3}, {tag-4}

---

## Context Card Notes

<!-- Anything the ContextCurator should know when building cards
     for this agent class that isn't captured by the tags alone.
     e.g. "Always include the proof template pattern if one exists
     for the task domain." -->

---

## Spec Test Results

<!-- Complete before marking Status: ACTIVE -->

| Test | Result | Notes |
|---|---|---|
| T-01 Name PascalCase | ✅ / ❌ | |
| T-02 Doer word suffix | ✅ / ❌ | |
| T-03/T-04 user-invokable | ✅ / ❌ | |
| T-05 Agent file ≤15 lines | ✅ / ❌ | |
| T-06 No file paths | ✅ / ❌ | |
| T-07 No policy refs | ✅ / ❌ | |
| T-08 Instructions ≤4 lines | ✅ / ❌ | |
| T-09 get_context_card call | ✅ / ❌ | |
| T-10 raise_uncertainty ref | ✅ / ❌ | |
| T-11 No task content | ✅ / ❌ | |
| T-12 All universal tools | ✅ / ❌ | |
| T-13 No 'agent' tool (EX/RE) | ✅ / ❌ | N/A if ORCH/OWNER |
| T-14 agents: list (ORCH) | ✅ / ❌ | N/A if not ORCH |
| T-15 No exec/verify conflict | ✅ / ❌ | |
| T-16 Reviewer read-only | ✅ / ❌ | N/A if not REVIEWER |
| T-17 Tool justifications | ✅ / ❌ | |
| T-18 Skill file exists | ✅ / ❌ | |
| T-19–21 Skill file clean | ✅ / ❌ | |
| T-22 Skill via VS Code only | ✅ / ❌ | |
| T-23 Class definition exists | ✅ / ❌ | |
| T-24 Type declared | ✅ / ❌ | |
| T-25 Threshold declared | ✅ / ❌ | |
| T-26 Reviewer threshold ≥0.9 | ✅ / ❌ | N/A if not REVIEWER |
| T-27 Owner gate authority | ✅ / ❌ | N/A if not OWNER |
| T-28 Pattern tags declared | ✅ / ❌ | |
| T-29 Registered in manifest | ✅ / ❌ | |

---

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | {date} | Initial definition |