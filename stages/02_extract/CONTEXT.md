# Stage 02 - Extract

Siloed, per-document extraction into one structured JSON. No inference,
no cross-document connection, no matching.

## Inputs

Working this run:
| File | Section | Why |
|------|---------|-----|
| `stages/01_intake/output/summary-statement.txt` | score lines + every Strengths/Weaknesses bullet | the grid and the quotes |
| `stages/01_intake/output/application.txt` | only sections a quote points at | the located excerpts |
| `stages/01_intake/output/case-header.md` | whole | face-page numbers |

Reference every run:
| File | Section | Why |
|------|---------|-----|
| `_shared/rules/rubric-2025.json` | `factors`, `schema.value_types`, `reverse_coding` | factor ids, value types, the formula |
| `_shared/schema/audit-table.md` | whole | the audit-table format |

Do NOT load: `_shared/rules/failure-modes.md` (matching is stage 03's
job and reading the table here biases extraction), any example case, any
later stage's contract.

## Process

1. Extract the grid as factor -> reviewer -> value. One cell per assigned
   reviewer per factor. Never average, never collapse to one number.
2. Reverse-code every item whose type declares `reverse_scored: true`:
   `scored_value = (max + min) - score`, using THAT type's min and max
   (criterion_1_9 -> 10 - raw; impact_10_90 -> 100 - raw). Persist `raw`
   and `scored` side by side on every such item. F3 is categorical and is
   never reverse-coded and never given a number.
3. Extract every Strengths and Weaknesses bullet as a verbatim quote with
   reviewer, factor heading, and polarity. Verbatim means character for
   character. Do not paraphrase, trim, or fix grammar.
4. For each weakness quote that points at a locatable part of the
   application, emit a `located_excerpts` record: source, section, page,
   and the verbatim excerpt. Later stages read these records and never
   reopen the application.
5. Count `n_items` (grid cells plus quotes) and `n_warnings` (any cell or
   quote that could not be read cleanly). Both ride the output.

## Outputs

- `output/extraction.json` with keys: `case_id`, `face_page`, `grid`,
  `critique_quotes`, `located_excerpts`, `n_items`, `n_warnings`.

## Audit table

Format: `_shared/schema/audit-table.md`.

| Check | Pass Condition |
|-------|----------------|
| Both numbers persisted | every 1-9 and 10-90 item carries both `raw` and `scored` |
| Reverse arithmetic | for every such item, `scored == (max + min) - raw` for its own type |
| F3 categorical | F3 values are `appropriate` or `gaps_flagged`, never numeric |
| Verbatim quotes | every quote string appears character for character in `summary-statement.txt` |
| Counts present | `n_items` and `n_warnings` are integers on the output |
| No matching | `extraction.json` contains no failure-mode id |

## Human check

Pick one weakness bullet at random in the PDF, then find that exact
sentence in `extraction.json` with your eyes. Character mismatch is a fail.
