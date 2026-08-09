# Baseline arm: metric pre-declared BEFORE the run (d.17, P0-3)

Declared 2026-08-08 before either arm was scored. Written first on purpose:
a metric chosen after seeing the output is not a metric.

## The integer

SCORE = (count of failure modes named with an exact id from the 14-mode
table in `_shared/rules/failure-modes.md`) + (count of critique quotes
reproduced verbatim, character for character, from the input case).

Nothing else counts. Fluency, length, and plausibility are not scored.

## The two arms

- TREATMENT: the workspace as built, with `failure-modes.md` loaded.
  Its output is `_shared/examples/reconstructed/case-01-below-payline/run/05-diagnosis.md`.
- BASELINE: a fresh subagent, separate session, never shown
  `failure-modes.md` or any part of this workspace. Its entire input is
  the case file plus the instruction to name one primary cause with
  evidence. Run and transcript in `run.md` in this folder.

## Falsifiability

If the baseline scores at or above the treatment, the table is not doing
work and that result is reported as-is in the README GAPS section. The
prediction being tested is that baseline names ZERO exact mode ids,
because the ids exist only in the file it was never given.

## Amendment, 2026-08-09: the verbatim-quote unit is the complete bullet

The metric as declared above said "critique quotes reproduced verbatim,
character for character" and did not define the unit. The n=1 run
(`run.md`) surfaced the ambiguity: an exact substring of a quote, or a
splice of two quotes joined with an ellipsis, satisfies "verbatim" read
loosely, and the baseline's score swings from 1 to 4 depending on the
reading.

Resolved to the STRICT reading, binding on every run scored from this
date forward:

- A quote counts only if it reproduces one COMPLETE critique bullet from
  the case, character for character, from the bullet's first character to
  its last. No trimming, no splices, no ellipses, no joined fragments.
- Each distinct bullet counts at most once per arm.

Why strict, and not loose: (1) the loose reading is inflatable, since
chopping one bullet into three exact substrings scores 3, so it rewards
fragmentation rather than fidelity; (2) the extraction contract in
`stages/02_extract/CONTEXT.md` already defines verbatim as character for
character at the bullet level, so the strict reading is the one the rest
of the workspace uses; (3) a spliced quotation is precisely the artifact
the treatment arm is claimed to prevent, so counting it for the baseline
would erase the difference under measurement.

The n=1 record in `run.md` predates this amendment and reports both
readings; it is left intact. All later rows are scored strict-only.
