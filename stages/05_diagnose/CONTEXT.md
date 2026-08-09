# Stage 05 - Diagnose

Name exactly one primary cause with its evidence chain, or refuse. Stop.

## Inputs

Working this run:
| File | Section | Why |
|------|---------|-----|
| `stages/04_verify/output/verification.json` | `candidates[]`, `validations[]`, counts | what survived verification |
| `stages/03_match/output/matches.json` | `grid_reading` | which cell moved |

Reference every run:
| File | Section | Why |
|------|---------|-----|
| `_shared/rules/failure-modes.md` | the matched modes' Cause lines only | canonical wording of the cause |
| `_shared/rules/ranking-opinion.md` | whole | how ties break |
| `_shared/schema/audit-table.md` | whole | the audit-table format |

Do NOT load: the raw application or summary statement, any prior
`output/` diagnosis from an earlier run, any example diagnosis, any
earlier stage's contract.

## Process

1. Apply the evidence threshold. It is a data rule, not a judgment call:
   a cause qualifies only if it has >= 2 verbatim critique quotes AND
   >= 1 moved grid cell traced to >= 1 located excerpt.
2. Zero causes qualify -> write `output/no-diagnosis.md` naming the exact
   shortfall (how many quotes, whether a grid cell moved, whether an
   excerpt was located). Then stop. Refusal is an output, not an error.
3. One cause qualifies -> that is the primary cause.
4. More than one qualifies -> break the tie by `ranking-opinion.md`,
   in its stated order. Ties that survive every rule go to
   `no-diagnosis.md` with both causes named, never to a compound answer.
5. Write the evidence chain explicitly: moved grid cell -> the verbatim
   quotes -> the located excerpt. Use the mode's canonical Cause wording.
6. Name ONE cause. No secondary causes, no recommendations, no rewrite
   suggestions, no next steps. The tool interprets an existing verdict; it
   does not advise. Then stop.

## Outputs

- `output/diagnosis.md` (one primary cause, evidence chain, counts), or
- `output/no-diagnosis.md` (shortfall named, counts).

## Audit table

Format: `_shared/schema/audit-table.md`.

| Check | Pass Condition |
|-------|----------------|
| Exactly one file | either `diagnosis.md` or `no-diagnosis.md` exists, never both |
| One cause | `diagnosis.md` names exactly one mode id from the table |
| Threshold met | the named cause cites >= 2 verbatim quotes and >= 1 grid cell with >= 1 excerpt |
| Refusal states shortfall | `no-diagnosis.md` names which of the three conditions failed |
| No advice | neither file contains a recommendation, a rewrite, or a next step |
| Counts present | `n_items` and `n_warnings` appear in the output file |

## Human check

Read the diagnosis to someone who has not seen the case and ask them to
point at the one sentence in the summary statement that proves it. If they
cannot find it in under a minute, the evidence chain is not shown.
