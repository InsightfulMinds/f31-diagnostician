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
