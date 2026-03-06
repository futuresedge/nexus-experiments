# Zone 0 — Framework Governance

## Purpose

Zone 0 is not a stage in the task lifecycle. It is the standing
governance layer that exists above and across all other zones. It
defines the rules, policies, and structures that the other zones
operate within.

Work in Zone 0 is framework work, not product work. Adding a new
agent class, revising a policy, running an experiment, updating the
pattern library — all of this is Zone 0 work.

## Authority

**FrameworkOwner** holds sole write authority in Zone 0.

No other agent or human actor may modify framework documents, policies,
schema definitions, or the pattern library without FrameworkOwner
approval. This is enforced at the tool level — only FrameworkOwner
holds `write_patterns` and the write tools for framework documents.

## Agent Activation

Zone 0 does not follow the standard task lifecycle. Work here is
managed as a direct session between human:director and FrameworkOwner.

Agents that may be activated in Zone 0:

- `FrameworkOwner` (primary)
- `TemplateAuthor` (for producing new agent templates)
- `SpecValidator` (for validating proposed agent class designs)
- `ContextCurator` (for pattern library maintenance)

## Zone 0 Gate

There is no automatic gate in or out of Zone 0. All Zone 0 work
is initiated and concluded by human:director with FrameworkOwner.

## Failure Handling

Framework uncertainties raised in Zone 0 are owned by FrameworkOwner.
They are not routed to UncertaintyOwner — Zone 0 failures are
framework design failures, not task execution failures, and must be
resolved at the source.