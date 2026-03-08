---
name: [AgentClassName]
description: "[One sentence. What single artefact does this agent produce?]"
model: claude-sonnet-4-5
tools:
  - get_context_card
  - get_my_capabilities
  - get_current_state
  - raise_uncertainty
  # Task-scoped tools are populated here at activation time.
  # See get_my_capabilities for the live list.
---

Call `get_context_card` to load your brief.
If uncertain at any point, call `raise_uncertainty`. Never proceed silently.
