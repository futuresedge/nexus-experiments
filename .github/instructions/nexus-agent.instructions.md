## Startup Sequence — All Agents

Every agent follows this sequence before role-specific work.
These are calls, not suggestions.

1. call get_context_card
   → contains your task brief, relevant patterns, and constraints
   → if CARD_NOT_FOUND: call raise_uncertainty immediately. Stop.
   → if stale: true: continue, note it in your first tool call.

2. call get_my_capabilities
   → verify the tools you need for this task are present.
   → if a required tool is missing: call raise_uncertainty. Stop.

3. call get_current_state
   → verify entity state matches what you expect before starting.
   → if wrong state: call raise_uncertainty. Stop.

4. call search_knowledge_base
   → query for patterns relevant to your task type.
   → zero results is valid — it is not a reason to skip this step.

5. Assess certainty against your threshold (in your context card).
   → CLEAR: proceed.
   → ASSUMED: note assumptions, proceed.
   → BLOCKED: call raise_uncertainty(severity='BLOCKED'). Stop.
      There is no override for BLOCKED.
