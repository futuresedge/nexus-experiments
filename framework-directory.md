# Framework directory

.                                           # workspace root
│
├── nexus/                                  # MCP server implementation
│   ├── server.ts
│   ├── webhook.ts
│   ├── webhook-parser.ts
│   ├── db.ts
│   └── schema.sql
│
├── .vscode/
│   └── mcp.json                            # MCP server registrations
│
├── .github/
│   ├── copilot-instructions.md             # always-on workspace rules
│   ├── agents/                             # active per-task agent specs (generated)
│   │   └── task-performer-task-07.agent.md # example generated instance
│   ├── skills/                             # loadable skill files
│   │   ├── nexus-tool-grammar.skill.md
│   │   ├── nexus-ontology.skill.md
│   │   ├── uncertainty-protocol.skill.md
│   │   ├── preflight-check.skill.md
│   │   └── context-compression.skill.md
│   └── instructions/                       # VS Code instruction files
│       └── agent-design.instructions.md
│
└── .framework/                             # everything below this line
    │                                       # is what we are designing now
    ├── manifest.md                         # ← THE framework manifest
    │
    ├── principles.md                       # ← P1–P17 guiding principles
    │
    ├── policies/                           # governance documents
    │   ├── tool-grammar.md                 # verb vocabulary, subject vocab, matrix
    │   ├── agent-creation-policy.md        # Zone 0 policy
    │   ├── context-curation-policy.md      # cross-cutting curation invariants
    │   ├── preflight-uncertainty-protocol.md
    │   └── agent-pair-registry.md          # all registered Agent Pairs
    │
    ├── schema/                             # ← the gap identified today
    │   ├── pattern-library-schema.md       # field definitions for pattern entries
    │   ├── context-card-schema.md          # required fields for every context card
    │   ├── audit-log-schema.md             # canonical audit_log row definition
    │   └── observable-stream-schema.md     # stream_events row definition
    │
    ├── templates/                          # blank forms — never filled in here
    │   ├── base-agent-template.md          # minimum valid agent spec structure
    │   ├── agent-class-requirements.md     # blank FOA requirements form
    │   ├── spec-tests-template.md          # blank Agent Spec QA test form
    │   ├── context-card-template.md        # blank context card form
    │   ├── pattern-library-entry.md        # blank Pattern Library entry form
    │   └── hypothesis-card-template.md     # blank experiment hypothesis form
    │
    ├── agent-classes/                      # approved agent class templates
    │   │                                   # (produced by Zone 0 cycles)
    │   ├── zone-0/
    │   │   ├── foa.agent.md
    │   │   ├── agent-spec-qa.agent.md
    │   │   └── agent-template-creator.agent.md
    │   ├── zone-3/
    │   │   ├── context-agent.agent.md
    │   │   └── qa-definition.agent.md
    │   ├── zone-4/
    │   │   ├── task-performer.agent.md     # base template (hydrated at activation)
    │   │   └── qa-execution.agent.md
    │   └── cross-cutting/
    │       └── uncertainty-owner.agent.md  # one per zone at instantiation
    │
    ├── context-tree.md                     # CONTEXT_TREE_REF target for all agents
    │
    ├── patterns/                           # Pattern Library entries
    │   │                                   # one file per registered pattern
    │   └── .index.md                       # machine-readable index for search_knowledge_base
    │
    ├── context-cards/                      # generated context cards
    │   │                                   # one per agent class (+ task variants)
    │   ├── foa.context-card.md
    │   ├── agent-spec-qa.context-card.md
    │   └── agent-template-creator.context-card.md
    │
    ├── bootstrap/                          # Zone 0 readiness artefacts
    │   ├── zone-0-readiness-checklist.md   # the proof template for bootstrapping
    │   └── decisions/                      # named FO decisions (immutable)
    │       └── 001-bootstrapping-exception.md
    │
    ├── experiments/                        # experiment records
    │   ├── exp-01/
    │   │   ├── hypothesis-cards.md
    │   │   ├── probe-results.md
    │   │   └── retrospective.md
    │   └── exp-02/
    │       └── hypothesis-cards.md
    │
    └── features/                           # active project work (runtime)
        └── <feature-slug>/
            ├── feature-spec.md
            ├── feature-ac.md
            └── tasks/
                └── <task-id>/
                    ├── task-spec.md
                    ├── task-ac.md
                    ├── context-package.md
                    ├── proof-of-completion.md
                    ├── qa-review.md
                    ├── work-log.md
                    └── uncertainty-log.md
