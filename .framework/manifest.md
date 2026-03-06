# Nexus Framework Manifest

**Version:** 0.1
**Status:** Active
**Principles Document:** .framework/principles.md (v1.0)
**Last Updated:** 2026-03-03

---

## Purpose

This manifest is the entry point for the Nexus framework. It records:
1. Named decisions that govern the framework as a whole
2. The canonical location of every governance document
3. The bootstrapping exception and its rationale
4. The version history of the framework itself

It does not contain policy. Policy lives in .framework/policies/.
It does not contain templates. Templates live in .framework/templates/.
It does not contain patterns. Patterns live in .framework/patterns/.

---

## Document Registry

| Document | Path | Version | Status |
|---|---|---|---|
| Guiding Principles | .framework/principles.md | 1.0 | Active |
| Tool Grammar | .framework/policies/tool-grammar.md | 0.2 | Active |
| Agent Creation Policy | .framework/policies/agent-creation-policy.md | 0.2 | Active |
| Context Curation Policy | .framework/policies/context-curation-policy.md | 0.1 | Active |
| Pre-flight & Uncertainty Protocol | .framework/policies/preflight-uncertainty-protocol.md | 0.1 | Active |
| Agent Pair Registry | .framework/policies/agent-pair-registry.md | 0.1 | Active |
| Base Agent Template | .framework/templates/base-agent-template.md | 0.2 | Active |
| Context Tree | .framework/context-tree.md | 0.1 | Active |

---

## Named Decisions

Named decisions are FO-level choices that govern the framework permanently.
They are recorded here because they have no natural home in any policy document.
They are immutable — to change them, a new decision supersedes the old one.

| ID | Decision | Date | Rationale |
|---|---|---|---|
| D-001 | Bootstrapping Exception | 2026-03-03 | See below |
| D-002 | OCAP over ACL | 2026-03-03 | See .framework/bootstrap/decisions/002-ocap-over-acl.md |
| D-003 | GitHub webhooks over MCP fork | 2026-03-03 | See .framework/bootstrap/decisions/003-webhooks.md |
| D-004 | read_ and search_ produce audit entries | 2026-03-03 | P5 compliance — every action recorded |
| D-005 | Edit tool is binary. MCP is the only available access control boundary. All non-code writes go through MCP tools. | 2026-03-03 | |
| D-006 | Skill and instruction files live in the VS Code layer. Governance is Zone 0 process + Git, not Nexus audit entries. | 2026-03-03 | |
| D-007 | Unscoped VS Code built-in reads are an accepted platform gap. Documented honestly, not papered over. | 2026-03-03 | |
| D-008 | Agent identity is expressed through tool possession, not tokens. OCAP is structurally stronger than any auth layer we could add. | 2026-03-03 | |
| D-009 | read_ and search_ verbs produce audit entries (grammar v0.3). The v0.2 distinction between "mutable state" and "versioned documents" was insufficient version numbers record what a document contained, not who read it or when. | 2026-03-03 | |
| D-010 | Agent files are ≤15 lines. Governance metadata lives in .framework/agent-classes/, never in the agent file itself. | 2026-03-03 | |

---

## Bootstrapping Exception (D-001)

The FOA and Agent Spec QA were created manually by FO on 2026-03-03
during initial framework setup. They could not be created by the Zone 0
process because Zone 0 did not yet exist.

This exception satisfies the Agent Pair invariant: FOA and Agent Spec QA
are a de-facto pair. FOA produces requirements and commissions; Agent Spec QA
tests and reviews. They were designed together, deployed together, and neither
is activatable in isolation.

This is the founding Agent Pair. All subsequent agents go through Zone 0.

Implementing principles: P8, P13, P17

---

## Future Directions

| ID | Direction | Trigger condition |
|---|---|---|
| F-001 | ONE Ontology as software design standard | When first real project is scoped through Zone 0 |

---

## Framework Version History

| Version | Date | Summary |
|---|---|---|
| 0.1 | 2026-03-03 | Initial manifest. Principles v1.0 established. |
|     |            | Tool Grammar v0.2 (P5 audit fix for read_ and search_). |
|     |            | Agent Creation Policy v0.2 (Agent Pair invariant). |
|     |            | Bootstrapping exception recorded as D-001. |

## Three-Layer Architecture
```
LAYER               DELIVERY MECHANISM          AUDIT COVERAGE
─────               ──────────────────          ──────────────

Agent file          VS Code reads from          None needed —
                    .github/agents/             identity only

Instructions        VS Code injects             None needed —
                    always-on                   startup rules only

Skills              VS Code injects             None needed —
                    at host layer               role knowledge

Context Card        MCP: get_context_card       ✅ Full — every
                    (Nexus layer)               fetch recorded

Task documents      MCP: read_{doc}_{task}      ✅ Full — every
                    (Nexus layer)               read recorded

Governance          MCP: read_ tools            ✅ Full
artefacts           (Nexus layer, FOA only)
```