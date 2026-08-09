# Stage 03 - Match

Match critique language to failure modes, over the extraction only.

## Inputs

Working this run:
| File | Section | Why |
|------|---------|-----|
| `stages/02_extract/output/extraction.json` | `grid`, `critique_quotes`, counts | the only evidence this stage sees |

Reference every run:
| File | Section | Why |
|------|---------|-----|
| `_shared/rules/failure-modes.md` | "How matching works" + the mode table | the ladder and the phrase maps |
| `_shared/schema/audit-table.md` | whole | the audit-table format |

Do NOT load: the application or summary statement text, any prior
`output/` content from an earlier diagnosis, any example case, any later
stage's contract. The tool never learns its patterns from its own past runs.

## Process

1. Read the grid first. Record which cells moved: which factor is worst,
   and whether F1 lags F2 or the reverse. Grid reading precedes matching.
2. For each critique quote, apply the five-strategy ladder in
   `failure-modes.md` in order, stopping at the first success.
3. Strategy 5 for F31 is NOT a midpoint fallback. There is no midpoint
   failure mode. An unmatched quote gets `mode: null, unmatched: true`
   and adds one to `n_warnings`. Never force a quote onto a near mode.
4. A quote matching two modes is recorded against both, with
   `ambiguous: true`. Ranking happens in stage 05, not here.
5. Carry `n_items` and `n_warnings` forward, updated with this stage's
   warnings.

## Outputs

- `output/matches.json`: `grid_reading`, `matches[]` (quote, mode, strategy,
  paraphrase, ambiguous, unmatched), `n_items`, `n_warnings`.

## Audit table

Format: `_shared/schema/audit-table.md`.

| Check | Pass Condition |
|-------|----------------|
| Every quote accounted for | `matches[]` length equals the number of quotes in `extraction.json` |
| No forcing | every entry has either a mode id from the table or `unmatched: true`, never a mode invented here |
| Strategy recorded | each match names which ladder strategy (1-5) produced it |
| Grid read first | `grid_reading` is present and names at least one moved cell |
| Counts carried | `n_items` and `n_warnings` present, warnings >= the count of unmatched entries |

## Human check

Count the weakness bullets in the summary statement PDF by hand and
compare that integer to the length of `matches[]`. They must be equal.
