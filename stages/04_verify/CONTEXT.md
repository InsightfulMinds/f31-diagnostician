# Stage 04 - Verify

Validate the numbers, then test each candidate cause against the located
excerpts. This stage never opens the source documents.

## Inputs

Working this run:
| File | Section | Why |
|------|---------|-----|
| `stages/03_match/output/matches.json` | whole | the candidate causes |
| `stages/02_extract/output/extraction.json` | `grid`, `face_page`, `located_excerpts` | the numbers and the application evidence |

Reference every run:
| File | Section | Why |
|------|---------|-----|
| `_shared/rules/rubric-2025.json` | `schema.value_types`, `validator_contract` | the three ranges and the categorical set |
| `_shared/schema/audit-table.md` | whole | the audit-table format |

Do NOT load: the raw application or summary statement, `failure-modes.md`
(matching is already done), any later stage's contract.

## Process

1. Range-validate as its own pass, separate from parsing:
   `is_valid(value, type_name) -> (bool, message)`, with the type name
   passed in, never assumed. criterion_1_9 accepts 1-9, impact_10_90
   accepts 10-90, percentile_0_100 accepts 0-100, categorical_commitment
   accepts only `appropriate` or `gaps_flagged`. Any failure is a warning
   with its message, not a silent correction.
2. For each candidate cause, look for a `located_excerpts` record that
   supports it. Supported means the excerpt shows the thing the reviewer
   said was missing or wrong. Absence of a supporting excerpt is recorded
   as `supported: false`, not as disproof.
3. Trace each moved grid cell to the quotes and excerpts attached to it.
   A cause with no moved cell behind it is `grid_supported: false`.
4. Do not rank and do not eliminate. Stage 05 decides.
5. Update `n_warnings` with every validation failure.

## Outputs

- `output/verification.json`: `validations[]`, `candidates[]` with
  `supported`, `grid_supported`, `excerpt_ids`, `n_items`, `n_warnings`.

## Audit table

Format: `_shared/schema/audit-table.md`.

| Check | Pass Condition |
|-------|----------------|
| Type-aware validation | every validated value names the type it was checked against |
| Three ranges honored | a 10-90 impact score is not rejected, and a 30 in a 1-9 slot is |
| No source reads | `verification.json` cites only excerpt ids from `extraction.json` |
| No ranking | `verification.json` contains no primary cause and no ordering |
| Counts carried | `n_items` and `n_warnings` present |

## Human check

Read one `supported: true` candidate and its excerpt aloud together. If
the excerpt does not visibly show what the reviewer complained about,
flip it to false by hand before stage 05 runs.
