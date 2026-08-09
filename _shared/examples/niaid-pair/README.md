# NIAID sample pair - extraction fidelity evidence ONLY

Credit: Text from the application is copyrighted. The awardee provided
express permission for NIAID to post the grant application and summary
statement for educational purposes, for nonprofit educational use only,
with the principal investigators, awardee organizations, and NIH NIAID
credited. Application and summary statement: Samantha Schwartz, Emory
University, 1 F31 AI133950-01, sponsor Graeme L. Conn; posted by NIH
NIAID. Source URLs in `/sources.md`.

## What this pair is for, and what it is NOT for

This application was FUNDED (impact score 17). It did not fail. It is
used here for ONE purpose: to prove that `stages/02_extract` reproduces a
real score grid and real verbatim critique quotes from a real summary
statement without drift. `verify-gate.sh` step 5a checks the extraction
against `expected-extraction.json`.

No diagnosis is ever run on this pair. Asking a diagnostician for the
cause of failure of an application that was funded is how a tool learns
to invent one. The demo diagnosis runs on the labeled reconstructed
below-payline case instead.

## Rubric-version caveat (honest gap)

This summary statement is from the 2017 review round, so its critique
headings are the pre-2025 FIVE-criterion fellowship format (Fellowship
Applicant; Sponsors, Collaborators, and Consultants; Research Training
Plan; Training Potential; Institutional Environment & Commitment to
Training). The workspace encodes the post Jan-25-2025 THREE-factor
rubric, which is the rubric a current applicant is reviewed under. No
public NIAID F31 pair reviewed under the 2025 criteria was available at
build time. The mapping used for extraction fidelity is recorded in
`expected-extraction.json` under `legacy_heading_map` and is explicitly
lossy. This is exactly the divergence failure mode 12 is about, which is
why it is stated rather than smoothed over.
