T-01  name is present and PascalCase
T-02  description is present and exactly one sentence
T-03  model field is present
T-04  tools list contains all five universal tools
T-05  file body is ≤ 15 lines excluding frontmatter
T-06  file contains no READS, WRITES, NEVER, ZONE, TYPE,
      or lifecycle blocks — these belong in the agent class
      definition, not the agent file
T-07  instruction text contains no more than 3 sentences
T-08  ZONE is present and valid
T-09  TYPE is present and valid
T-10  QA_TIER is present, integer 0–4
T-11  CERTAINTY_THRESHOLD is present, float 0.0–1.0
T-12  REVIEWER is present and does not equal name  ← P8 invariant
T-13  PRINCIPLES lists at least one P-ID
T-14  READS_VIA uses MCP tool name patterns, not file paths
T-15  WRITES_VIA contains at least one write_ or submit_ pattern
T-16  NEVER_MCP section is present and non-empty
T-17  NEVER_CONVENTION section is present and non-empty
      (honest documentation of Gap 1 from platform-constraints.md)
T-18  PATTERN_REF present on approved classes
T-19  REVIEWER pairing is registered in the Agent Pair Registry
      (no agent is an island — P8 requires a registered reviewer)

T-22  SKILL field in agent class definition references a file that
      exists at .github/skills/[skill-name].skill.md
      NOTE: VS Code delivers this — no read tool required or permitted.
      A read_ tool for a skill file is a spec test failure.
