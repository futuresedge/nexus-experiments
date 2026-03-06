# Agent File Template

**For:** All agent classes
**Constraint:** ≤15 lines of content (excluding --- delimiters)
**Reference:** Agent Design Standards v1.0, Platform Constraints v1.0

---

## EXECUTOR / REVIEWER (user-invokable: false)

```markdown
---
name: {AgentClassName}
description: "{One sentence, active voice — what this agent actively does.}"
user-invokable: false
tools:
  - get_context_card
  - get_my_capabilities
  - get_current_state
  - raise_uncertainty
  - {role_scoped_tool_1}
  - {role_scoped_tool_2}
---

Call `get_context_card` to load your brief before starting.
{One sentence primary directive — what to do, not how to do it.}
Call `raise_uncertainty` immediately if blocked or uncertain.
```

---

## ORCHESTRATOR (user-invokable: true, delegates to subagents)

```markdown
---
name: {AgentClassName}Orchestrator
description: "{One sentence — what workflow this orchestrator coordinates.}"
user-invokable: true
tools:
  - agent
  - get_context_card
  - get_my_capabilities
  - get_current_state
  - raise_uncertainty
  - {role_scoped_tool_1}
agents:
  - {SubagentClassName1}
  - {SubagentClassName2}
  - {SubagentClassName3}
---

Call `get_context_card` to load your brief.
Delegate to {SubagentClassName1}, then {SubagentClassName2} and
{SubagentClassName3} in parallel. Synthesise results.
Call `raise_uncertainty` if any subagent returns failure.
```

---

## OWNER (user-invokable: true, holds gate authority)

```markdown
---
name: {Domain}Owner
description: "{One sentence — what domain this Owner has authority over.}"
user-invokable: true
tools:
  - get_context_card
  - get_my_capabilities
  - get_current_state
  - raise_uncertainty
  - {write_domain_doc}
  - {submit_or_request_tool}
---

Call `get_context_card` to load your brief.
{One sentence — what authority decision this Owner makes.}
Call `raise_uncertainty` before any irreversible state transition
if confidence is below your certainty threshold.
```

---

## Line Count Check

Count content lines only (not --- delimiters, not blank lines before
first content, not trailing blank lines).

If your agent file exceeds 15 content lines, the excess belongs in:
- The skill file (role knowledge)
- The context card (task knowledge)
- The agent class definition (governance record)

Not in the agent file. The agent file is an identity declaration,
not a specification.