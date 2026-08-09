# Stage 01 - Intake

Normalize the two case documents into one case header plus two text files.

## Inputs

Working this run:
| File | Section | Why |
|------|---------|-----|
| the case's application document | whole | becomes `application.txt` |
| the case's summary statement | whole | becomes `summary-statement.txt` |
| `setup/questionnaire.md` | all 8 questions | answers become the case header |

Reference every run:
| File | Section | Why |
|------|---------|-----|
| `_shared/rules/paylines.md` | "Threshold rule" | decide inside/outside payline |
| `_shared/schema/audit-table.md` | whole | the audit-table format |

Do NOT load: `_shared/rules/failure-modes.md`, `rubric-2025.json`, any
example case, any other stage's contract. Intake does no interpretation.

## Process

1. Answer all 8 questionnaire items. Any unanswered item stops the run.
2. If either document is missing, stop and write `output/blocked.md`
   naming the missing document. Do not proceed on one document.
3. If question 3 answers "no" (pre-2025 review round), stop: this
   workspace encodes only the 2025 three-factor rubric.
4. Convert both documents to plain UTF-8 text. Preserve line breaks and
   heading text exactly. No summarizing, no cleanup, no reordering.
5. Write `case-header.md`: handle, IC, FY, impact score, percentile,
   payline, inside/outside, submission number. Numbers only, no commentary.

## Outputs

- `output/case-header.md`
- `output/application.txt`
- `output/summary-statement.txt`
- or `output/blocked.md`

## Audit table

Format: `_shared/schema/audit-table.md`.

| Check | Pass Condition |
|-------|----------------|
| Both documents present | `application.txt` and `summary-statement.txt` both exist and are non-empty, or `blocked.md` exists and names which is missing |
| Rubric version | case-header records the review round as post 2025-01-25 |
| Payline decision | case-header carries percentile, payline, and the literal word inside or outside |
| No interpretation | case-header contains no sentence about why the application scored as it did |

## Human check

Open `output/summary-statement.txt` and the original PDF side by side and
read the reviewer score lines out loud from both. The numbers must match.
