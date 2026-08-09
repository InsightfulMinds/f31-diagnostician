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
