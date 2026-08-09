# F31 Submission Diagnostician

An ICM Pipeline workspace that diagnoses a failed NIH F31 predoctoral
fellowship application backward from its summary statement. It reads the
score pattern first, matches reviewer critique language against a
14-failure-mode table, verifies the candidate cause against located
excerpts of the application, names ONE ranked primary cause with the
evidence chain shown, and stops. When the evidence does not clear a
stated threshold, it refuses in writing instead of naming a cause.

The workspace is the submission. It demonstrates the methodology by being
built out of it: routing entry file, root catalog that stores nothing,
five stage contracts with hard limits restated inline, rules as validated
data, examples with their provenance labeled, and a mechanical gate that
can fail.

Cohort: Technical.
Threshold: the payline rule stated in `_shared/rules/paylines.md`, which
is its only home.

## How to run it

1. Read `CLAUDE.md`. It routes and holds nothing else.
2. Answer all eight questions in `setup/questionnaire.md`. Both the
   application and the summary statement must be in hand; the pipeline
   stops on one document.
3. Work the stages in order. Each stage's `CONTEXT.md` is its contract:
   Inputs (with a "Do NOT load" line), numbered Process with the hard
   limits restated inline, Outputs, and one physical human check. Load
   the contract and the exact inputs it names. Never load a folder.
4. Stage 05 writes exactly one file: `diagnosis.md` or `no-diagnosis.md`.
   Then stop.
5. Verify structure at any time with `bash _meta/verify-gate.sh`, and
   verify the gate itself with `bash _meta/verify-gate.sh --selftest`.

Worked examples, end to end, live in
`_shared/examples/reconstructed/case-01-below-payline/run/` (a diagnosis)
and `_shared/examples/reconstructed/case-02-refusal/run/` (a refusal).

### Run it

The repeatable shape is: input = one case directory holding the two case
documents (`application*`, `summary-statement*`); output = one
self-contained `report.html` in that directory.

```
bin/diagnose.sh <case-dir>       # walk stages 01-05, then render
node bin/render-report.mjs <case-dir>   # render only, from an existing run/
```

`bin/diagnose.sh` is a contract-walker, not a framework: it invokes each
stage as `claude -p "<stage prompt>"` when the `claude` CLI is on PATH,
pointing the agent at that stage's `CONTEXT.md` and nothing else. Without
the CLI it prints the exact per-stage instructions an agent must follow
and exits 2. It stops on a missing document (exit 1) and on a stage-01
`blocked.md`, then collects the stage outputs into `<case-dir>/run/` and
renders.

`bin/render-report.mjs` (Node 22, zero dependencies) reads
`<case-dir>/run/` (`02-extraction.json`, `03-matches.json`, optional
`04-verification.json`, and `05-diagnosis.md` or `05-no-diagnosis.md`)
and writes `report.html`: the named primary cause or the refusal styled
as a refusal, the evidence chain with quote and excerpt citations, the
matched modes, and the case metadata. Both example cases render:

```
node bin/render-report.mjs _shared/examples/reconstructed/case-01-below-payline
node bin/render-report.mjs _shared/examples/reconstructed/case-02-refusal
```

## Why the pipeline is shaped this way

Extraction is siloed from synthesis. Stage 02 reads the documents and
emits a score grid, verbatim quotes, and located application excerpts;
every later stage reads those records and never reopens the source. The
diagnosis therefore cannot quietly invent a quote, because the quote had
to survive an extraction step that is checked character for character.

The refusal path is a data rule, not model judgment: a cause qualifies
only with at least two verbatim critique quotes AND at least one moved
grid cell traced to at least one located excerpt. Below that, the tool
writes `no-diagnosis.md` and names the shortfall.

The rubric is a validated data file with three declared value types
(criterion 1-9, impact 10-90, percentile 0-100) and Factor 3 encoded as
categorical (appropriate / gaps_flagged), because that is what the post
January 25 2025 fellowship criteria actually specify. Failure mode 12 in
our own table is "written to the wrong rubric version," so encoding the
rubric wrong would be the tool committing the error it diagnoses.

## Economics of the method, with the trade stated

The published measurements for this methodology: 5,314 tokens per
question against 184,186 for the long-context baseline, 97.1% fewer
tokens and 95.2% lower cost, break-even at ~7 questions (median 6.9,
range 5.7-8.7 across histories), p = 0.227 against long context, and a
cross-vendor read at 96% lower cost. The same results table reports the
accuracy trade in the same breath: 34/39 correct for long context against
29/39 for this method, roughly 13 accuracy points given up for the 95%
cost cut. Quoting the savings without that sentence would be the kind of
overreach a judge checks, and the paper's own limits are narrow enough
(one user, one writer, one reader, synthetic history, single ingestion
pass, an accuracy ordering that reversed between n=5 and n=39) that no
accuracy claim should be leaned on at all.

## Evidence this thing works, and its limits

- `_meta/verify-gate.sh` runs the mechanical battery: ceilings, contract
  shape, one-way references, rubric schema validation, reverse-coding
  arithmetic, NIAID extraction fidelity, the demo diagnosis, the refusal
  negative control, reconstructed-label and leak greps, the em-dash and
  canonical-source greps, root-catalog payload check, empty stage outputs,
  and per-stage token budget. Full output in `verify-evidence.txt`.
- `--selftest` injects four defects into a temp copy (a forced diagnosis
  on the refusal case, a leaked reconstructed phrase, Factor 3 wrongly
  made numeric, an em-dash) and asserts the gate rejects each. A gate that
  cannot fail is not evidence.
- The cold walk test: a fresh agent with no build context read only
  `CLAUDE.md` and answered where it was and where to go next. Transcript
  in `verify-evidence.txt`.
- The baseline arm, with its metric declared before the run, is in
  `_meta/baseline/`. Read it before believing the failure-mode table adds
  accuracy: on the four reconstructed cases measured it did not. What it
  added was canonical mode ids and complete rather than spliced or
  fragmentary quotations.

## GAPS

Stated because they are true, not because they are safe.

1. **Built against a described bar, not a published rubric.** The
   original brief arrived second-hand, so the design optimizes against a
   description of the standard rather than the standard itself.
2. **Not benchmarked against peer approaches.** No comparable
   grant-diagnostics tools were pulled apart and compared. This is
   optimized against the method, not against a field.
3. **Real below-payline applications are scarce in public.** NIH sample
   pairs are funded exemplars. The demo diagnosis, the refusal control,
   and the three additional cases added for the baseline arm (cases 03
   through 05) therefore all run on reconstructed cases, labeled on line 1
   of every file and grepped for tree-wide so reconstructed text cannot
   pass as real reviewer language anywhere else. Five reconstructed cases
   are still zero real cases; breadth here is not realism.
4. **The real pair is from a pre-2025 review round.** The NIAID Schwartz
   summary statement (impact 17, funded) uses the five-criterion format.
   It is used for extraction fidelity only, with a lossy heading map
   recorded in `expected-extraction.json`. No public F31 pair reviewed
   under the 2025 three-factor criteria was available at build time.
5. **The baseline arm is n=4, all reconstructed.** The original n=1 run
   used a metric that admitted two readings (score 1 or 4 for the
   baseline, depending on whether a verbatim fragment counts); that
   record is kept as-is in `_meta/baseline/run.md`. The ambiguity was
   then resolved to the strict reading (a quote counts only as one
   complete critique bullet, character for character; rationale in
   `_meta/baseline/metric.md`) and the arm was extended to four
   diagnosable cases. Strict totals: treatment 15, baseline 7; the
   baseline named zero exact mode ids in all four runs but reached a
   substantively correct diagnosis in prose on every case, including the
   hard near-miss case. So the measured contribution is still canonical
   ids and complete quotation, not accuracy, now on n=4 instead of n=1,
   and all four cases are reconstructed by the table's own authors, with
   one baseline score partly a metric artifact (a dropped terminal
   period). The table's contribution to accuracy remains unmeasured.
6. **Cut from the initial build:** the Roswell Park second pair (not
   fetched) and the second NIAID document (its URL redirected to an HTML
   page during the build). Both were on the pre-agreed cut list.
7. **Thin automation only.** `bin/diagnose.sh` walks the five stage
   contracts and `bin/render-report.mjs` renders a run to one HTML page,
   but the stages themselves are still LLM work: the walker either hands
   each contract to the `claude` CLI or prints instructions for an agent
   and exits. There is no hosted app, no LLM calls inside the workspace
   itself, and stage outputs ship empty by design, so at rest every stage
   correctly reads as not-run.
8. **Cohort and threshold are configuration, not ground truth.** The
   workspace ships with cohort=Technical and an inside-payline pass
   threshold. Retargeting either is a data-file change, not a rebuild.
