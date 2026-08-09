# F31 Submission Diagnostician (ICM Pipeline)

You are inside an ICM Pipeline workspace that diagnoses a failed NIH F31
predoctoral fellowship application backward from its summary statement.
It names ONE ranked primary cause with the evidence chain shown, or refuses.

## Where you are

Root of the workspace. This file routes. It holds no payload.

## First run

1. Read `CONTEXT.md` (root catalog: what lives where).
2. Fill `setup/questionnaire.md` with the case being diagnosed.
3. Enter `stages/01_intake/` and follow its `CONTEXT.md`.

## The pipeline

Stages run in order. Each stage folder has a `CONTEXT.md` contract
(Inputs, Process, Outputs, Human check), a `references/` folder, and an
`output/` folder. Read ONLY the current stage's contract plus the exact
inputs it names. Never load a whole folder.

- `stages/01_intake/` normalize the two case documents
- `stages/02_extract/` siloed per-document extraction to JSON
- `stages/03_match/` failure-mode matching over the extraction JSON
- `stages/04_verify/` range validation + evidence verification
- `stages/05_diagnose/` one primary cause, or `no-diagnosis.md`

## Shared material

- `_shared/rules/` rubric data file, failure-mode table, paylines
- `_shared/examples/` real NIAID pair + labeled reconstructed cases
- `_shared/schema/` the stage audit-table template
- `_meta/` walk test, verify gate, baseline record

## Hard rules

- Text under `_shared/examples/reconstructed/` is reconstructed, never
  real reviewer language. Do not quote it anywhere outside that folder.
- No stage loads another stage's contract, or any prior `output/` content.
- Stop after `05_diagnose` writes its single file. Do not iterate.
