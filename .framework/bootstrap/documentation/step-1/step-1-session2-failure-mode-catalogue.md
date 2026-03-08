# Part 6 — Failure Mode Catalogue

The most consequential failure modes across all four tasks:

| Task | Subtask | Failure Mode | Downstream consequence |
|---|---|---|---|
| 1.2 | Subtask 1 | Multiple `techstack` gaps collapsed into one entry | Task 1.3 asks one compound question; answer is a paragraph; downstream decomposition re-does Task 1.2 work |
| 1.2 | Subtask 1 | `appetite` classified non-BLOCKER because Step 2 doesn't use it | Gate 3 not applied; question never asked; Task 1.4 invents enum value; manifest fails DoD 3 |
| 1.2 | Subtask 1 | `deploymenttarget` classified PRESENT because "Cloudflare Workers" is explicit | Ambiguity between Workers and Pages undetected; wrong adapter used in Step 2 |
| 1.2 | Subtask 3 | Contradiction downgraded to WARNING using domain knowledge | Contradiction never reaches human; one side of an unresolved conflict enters the manifest |
| 1.2 | Subtask 3 | OQ-1-05/OQ-1-10 linkage not set bidirectionally | Task 1.3 asks two questions about the same issue; human receives duplicate questions |
| 1.2 | Subtask 4 | Non-mappable subtask skipped entirely | S-13 (Cloudflare account readiness) disappears; Step 2 incorrectly assumes DNS procurement needed |
| 1.3 | Subtask 1 | Compound question for `deploymenttarget` + SSR | FC-3 violation; design preference embedded in clarification question |
| 1.3 | Subtask 3 | OQ-1-10 not cascade-updated after OQ-1-05 RESOLVED | Manifest exits with one resolved and one unresolved entry for the same underlying issue |
| 1.3 | Subtask 3 | "Latest stable" treated as a final value | Task 1.4 writes placeholder into manifest; format rule violated; Step 2 receives non-specific version |
| 1.3 | Subtask 3 | `UNCLEAR` treated as `RESOLVED` | Hedged answer produces incorrect register value; error propagates into manifest |
| 1.4 | Subtask 1 | Pre-drafting step skipped | AstroJS and Shadcn version placeholders survive into DRAFT manifest |
| 1.4 | Subtask 2 | `@astrojs/react` not detected as implicit dependency | `techstack` incomplete; Step 2 `framework.integrations` section cannot be written |
| 1.4 | Subtask 2 | Traceability written after manifest rather than alongside | `description` source attribution unreliable; assembled field provenance becomes reconstruction |
| 1.4 | Subtask 3 | `integrationrequirements` populated with `provider: Formspree` | Unconfirmed provider becomes a manifest value; Step 2 builds integration section around an invented choice |
| 1.4 | Subtask 5 | Self-check run after `status: DRAFT` is set | DRAFT signals readiness; unverified manifest reaches Task 1.5 review |
| 1.5 | Subtask 1 | Part 2 (open questions) omitted from review package | Alex approves without knowing about WARNING-level gaps; approval not informed consent |
| 1.5 | Subtask 3 | "Looks good to me" classified as `APPROVED` | FC-4 audit record lacks explicit deliberate affirmation; approval is not independently verifiable |
| 1.5 | Subtask 3 | Embedded correction ignored | APPROVED set; manifest contains value Alex explicitly said was wrong in their approval response |
| 1.5 | Subtask 4 | Old traceability entry deleted when correction applied | History of field change lost; verifier cannot confirm the value changed rather than always being the corrected value |
| 1.5 | Subtask 5 | `approvedat` set to executor processing time | Audit trail misrepresents the timeline; particularly significant in asynchronous workflows |
| 1.5 | Subtask 5 | `approvedby: "humandirector"` (role title) | FC-4 requires named person attribution; role title is not independently verifiable |
| 1.5 | Post-approval | Traceability record updated after `status: APPROVED` | Companion record modified post-seal; approved state no longer fully intact |
