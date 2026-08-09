# Baseline arm: run and result (d.17)

Metric declared before the run in `metric.md`. Do not read this file
before that one.

## How the baseline was run

A fresh subagent in a separate session, model sonnet, was given exactly
one instruction: read `_shared/examples/reconstructed/case-01-below-payline/input-case.md`
and nothing else, no directory listing, no web, then name the one primary
cause with evidence. It was never shown `failure-modes.md`, the rubric
file, any stage contract, or any other part of this workspace. It could
not have read the table it was being tested against.

## Result on the pre-declared metric

| Arm | Exact mode ids named | Verbatim critique quotes | SCORE |
|-----|---------------------|--------------------------|-------|
| TREATMENT (table loaded) | 1 (`mode-06-record-not-argued`) | 3 complete quotes, all verbatim | 4 |
| BASELINE (no table) | 0 | see the ambiguity below | 1 or 4 |

The baseline named zero exact mode ids, which was the prediction, and it
is the only part of the metric that separated the arms cleanly.

## Where the pre-declared metric turned out to be ambiguous

The metric said "critique quotes reproduced verbatim, character for
character" and did not say whether a fragment counts. The baseline quoted
four passages. All four are exact substrings of the case. Only one is a
complete critique quote; the other three are fragments, one of them a
splice of two separate quotes joined with an ellipsis.

- Strict reading (complete quote): baseline 1, so SCORE 1 against the
  treatment's 4.
- Loose reading (any exact substring): baseline 4, so SCORE 4, a TIE.

Both numbers are reported because the metric as written admits both, and
picking the flattering one after seeing the output is the failure this arm
exists to guard against. Pre-declaring a metric did not save us from
under-specifying it; that is a real finding about the method, not a
footnote.

## What this does and does not show

It does NOT show that the table makes the diagnosis better. The baseline
reached a substantively similar conclusion in prose, unprompted, from the
case alone. On this one case, with this one model, the table's measured
contribution is a canonical mode id and complete rather than spliced
quotations, not a different or more accurate answer.

It also does not generalize: n = 1 case, 1 model, 1 run, and the case is
reconstructed. The honest claim is that the table makes the output
auditable and repeatable, not that it makes the model smarter. Any
stronger claim would need a real corpus and multiple runs, which is
recorded in the README GAPS section.

NOTE (2026-08-09): everything above predates the metric amendment in
`metric.md` and is left intact. Its scoring used the metric as originally
written, which admitted the two readings it reports. Every row below is
scored under the amended STRICT rule only: a quote counts only as one
complete critique bullet, character for character, first character to
last; each bullet counts once.

## Extension to n=4, 2026-08-09 (strict metric)

Three new diagnosable reconstructed cases were added (cases 03, 04, 05,
each targeting a different failure mode; see
`_shared/examples/reconstructed/README.md`). For each, the treatment arm
is the committed pipeline run in that case's `run/` folder, and the
baseline arm was a fresh subagent, separate session, model sonnet, given
one instruction: read that case's `input-case.md` and nothing else, no
directory listing, no web, then name the one primary cause with evidence.
None of the baseline agents saw `failure-modes.md`, the rubric file, any
stage contract, or any other part of this workspace.

To keep reconstructed text inside its labeled folder, this record cites
quotes by their extraction ids (q1..q3 per case), never by text. Each
baseline quotation was compared character for character against the
case's extraction bullets by script.

| Case | Arm | Exact mode ids | Complete verbatim quotes | SCORE (strict) |
|------|-----|----------------|--------------------------|----------------|
| case-01 | TREATMENT | 1 | 3 | 4 |
| case-01 | BASELINE  | 0 | 1 (of 4 quoted passages, 3 were fragments/splices) | 1 |
| case-03 | TREATMENT | 1 | 3 | 4 |
| case-03 | BASELINE  | 0 | 3 (q1, q2, q3 all complete) | 3 |
| case-04 | TREATMENT | 1 | 3 | 4 |
| case-04 | BASELINE  | 0 | 0 (q2 and q3 quoted minus their final period; fragments under strict) | 0 |
| case-05 | TREATMENT | 1 | 2 | 3 |
| case-05 | BASELINE  | 0 | 3 (q1, q2, q3 all complete) | 3 |

Totals, strict: TREATMENT 15, BASELINE 7. Baseline named zero exact mode
ids in all four runs, which remains the only clean separator and was the
pre-declared prediction.

## What the n=4 result does and does not show

Read before quoting the totals:

- Substantively, the baseline got the right answer in prose on every
  diagnosable case, including the hard case (05), where it identified the
  aim-dependency structure and even declined the tempting alternative on
  its own. On case 04 it named the sponsor/funding gap correctly. The
  table did not make any diagnosis more accurate on these cases.
- The measured contribution of the workspace is, as at n=1: canonical
  mode ids (4 vs 0) and complete rather than fragmentary quotation
  (11 vs 7 complete quotes). That is auditability, not intelligence.
- The case-04 baseline score of 0 is partly a metric artifact: both its
  quotations were exact except for a dropped terminal period. The strict
  rule counts them as fragments. Reported as scored, with this caveat
  attached, because bending the rule after seeing the output is the
  failure this arm exists to guard against.
- The baseline outputs also gave advice (resubmission fixes), which the
  treatment contract forbids; the metric does not score this difference.
- Still weak evidence: 4 cases, 1 model, 1 run each, all four cases
  reconstructed BY THE SAME AUTHORS as the table being tested, and cases
  03-05 were written knowing the metric. The treatment arm can only miss
  the mode id by pipeline error, so the mode-id half of the metric favors
  it by construction. The accuracy contribution of the table remains
  unmeasured; measuring it needs real cases and blind authorship.
