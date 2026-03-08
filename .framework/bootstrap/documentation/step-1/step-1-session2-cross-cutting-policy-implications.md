# Part 9 — Cross-Cutting Policy Implications

Items that surfaced during Task 1.2–1.5 analysis which affect FC policies, not just step policies.

| FC Policy | Implication | Session evidence |
|---|---|---|
| **FC-2** | Gate 3 (required field validity) must be documented as a separate, independent gate alongside Gates 1 and 2. The `appetite` case demonstrates that a required field can fail Gate 3 while returning NO on Gate 1 — Gate 2-only classification misses it. | Task 1.2 Subtask 1, `appetite` entry |
| **FC-2** | `POTENTIAL-CONTRADICTION` as a WARNING-level pre-flag for domain-knowledge-dependent contradictions. Not all contradictions are detectable without domain expertise. | Task 1.2 Subtask 3, Workers/static case |
| **FC-3** | Parenthetical retrieval instructions permitted — not compound questions. Max 25-word rule should explicitly carve out single-sentence retrieval instructions. | Task 1.3 Subtask 1, Q6 Node.js case |
| **FC-3** | `DECISION-REQUIRED` is not covered by FC-3. FC-3 resolves *missing declared information*. A human who has not decided what they want cannot be clarified — they must decide. This is a gap in the framework's coverage between FC-3 and whatever decision-support mechanism exists. | Task 1.3 Subtask 3 |
| **FC-3** | "One question per item, not a consolidated list" must be clarified to mean: "one question per gap; all questions delivered in one batch." Current wording is ambiguous. | Task 1.3 Subtask 2 |
| **FC-4** | Review record (`RR-xx`) must be defined as a distinct FC-4 Tier 1 artefact, separate from the clarification exchange record series (`CE-xx`). The document taxonomy must contain both series with distinct schemas. | Task 1.5 Subtask 2 |
| **FC-4** | `approvalstatement` (verbatim, minimum 5 words) must be a required field in the Tier 1 audit log entry. Currently the specification does not require this. | Task 1.5 Subtask 5 |
| **FC-4** | `approvedat` = human action timestamp, not executor processing timestamp. Asynchronous workflows make this distinction non-trivial. Must be stated explicitly. | Task 1.5 Subtask 5 |
| **FC-5** | Two new `sourcetype` values needed: `correction` (for Task 1.5 correction-sourced values) and an implicit `supersedes` link field (for correction chains). FC-5's current sourcetype list does not include these. | Task 1.5 Subtask 4 |
| **FC-5** | Post-approval immutability must explicitly extend to the companion traceability record, not just the primary document. Modifying the traceability record post-approval is functionally equivalent to modifying the manifest. | Task 1.5 Subtask 5 |
| **FC-8** | The document taxonomy must distinguish CE, RR, and CR artefact series. Currently FC-8 focuses on the register but does not define the full set of clarification/review/correction artefacts that Steps 1–6 produce. | Task 1.3, Task 1.5 |
