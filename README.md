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

Cohort: Technical, per recommendation.md, pending Sean's confirmation.
Threshold: the payline rule stated in `_shared/rules/paylines.md`, which
is its only home, per recommendation.md, pending Sean's confirmation.

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
  accuracy: on this one case it did not. What it added was a canonical
  mode id and complete rather than spliced quotations.

## GAPS

Stated because they are true, not because they are safe.

1. **The judging criteria are second-hand.** They reach us through task
   cards, not a published rubric. We optimized against a description of
   the bar.
2. **The 33-submission field was never opened.** No winner repo, no
   shortlist entry was pulled. This is optimized against the method, not
   against the competition.
3. **Real below-payline applications are scarce in public.** NIH sample
   pairs are funded exemplars. The demo diagnosis and the refusal control
   therefore run on reconstructed cases, labeled on line 1 of every file
   and grepped for tree-wide so reconstructed text cannot pass as real
   reviewer language anywhere else.
4. **The real pair is from a pre-2025 review round.** The NIAID Schwartz
   summary statement (impact 17, funded) uses the five-criterion format.
   It is used for extraction fidelity only, with a lossy heading map
   recorded in `expected-extraction.json`. No public F31 pair reviewed
   under the 2025 three-factor criteria was available at build time.
5. **The baseline arm is n=1.** One case, one model, one run, on a
   reconstructed case, with a metric that turned out to admit two
   readings (score 1 or 4 for the baseline against 4 for the treatment,
   depending on whether a verbatim fragment counts). Both readings are
   reported in `_meta/baseline/run.md`. The table's contribution to
   accuracy is unmeasured.
6. **Cut from tonight's build:** the Roswell Park second pair (not
   fetched) and the second NIAID document (its URL redirected to an HTML
   page during the build). Both were on the pre-agreed cut list.
7. **No live automation.** The pipeline is agent-run-by-contract. There is
   no hosted app, no LLM calls inside the workspace, and stage outputs
   ship empty by design, so at rest every stage correctly reads as not-run.
8. **Cohort and threshold are recommendations, not decisions.** Both are
   marked pending Sean's confirmation above and nothing has been submitted
   anywhere.
