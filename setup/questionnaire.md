# Case intake questionnaire

Answer every line before entering `stages/01_intake/`. Answers become
`stages/01_intake/output/case-header.md` fields.

1. Which submission is being diagnosed? (applicant handle, activity code
   must be F31, council round)
2. Files present? (application PDF or text: yes/no; summary statement:
   yes/no. BOTH are required. Missing either one stops the run.)
3. Was the application reviewed under the post Jan-25-2025 three-factor
   fellowship criteria? (If no, stop: this workspace encodes only the
   2025 rubric.)
4. Assigned IC (institute/center) and fiscal year?
5. Overall impact score and percentile (from the summary statement face
   page)?
6. The IC's published payline for that FY and activity code (looked up at
   intake from the sources in `_shared/rules/paylines.md`)?
7. Funded or unfunded? If unfunded and inside payline, note it: this tool
   diagnoses score-driven failures only.
8. First submission or resubmission (A1)?
