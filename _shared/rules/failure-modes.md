# The 14 failure modes (canonical home)

This file is the ONLY authority for the failure-mode table and its
reviewer-phrase maps. Every other file links here. Derived from the
2026-08-07 research pass (recommendation.md) against public NIH reviewer
guidance and critique-writing guides; source URLs in `/sources.md`.

Factor ids refer to `_shared/rules/rubric-2025.json` (F1 Candidate's
Preparedness and Potential, F2 Research Training Plan, F3 Commitment to
Candidate).

## How matching works: the five-strategy ladder

Apply in order to each extracted critique quote. Stop at first success.
Never discard a quote.

1. Explicit structured statement: the critique itself names the pattern
   (rare in summary statements).
2. Labeled value: a weakness bullet sits under a factor heading AND
   contains a phrase from exactly one mode's phrase map.
3. First valid in-range match: the quote contains a phrase from exactly
   one mode's phrase map, factor heading unknown.
4. Controlled phrase-to-mode map: the quote paraphrases a map phrase
   (same head noun + same complaint verb class); record `paraphrase: true`.
5. UNMATCHED: no map phrase hits. Set `mode: null, unmatched: true`, add
   one to `n_warnings`. There is no midpoint failure mode. A quote is
   NEVER forced onto the nearest mode.

## Mode table

Each entry: Cause (one sentence, canonical), grid signature, phrase map.

### mode-01-mini-r01
Cause: the research plan is argued as a standalone science project while its training value to this candidate goes unstated.
Grid: F2 midrange, F1 dragged down relative to the record.
Phrases: "connection between the project and the candidate's training goals is unclear", "reads like an R01", "training value of the proposed work is not articulated".

### mode-02-descriptive-aims
Cause: specific aims are framed as descriptive questions rather than hypothesis-driven mechanism questions.
Grid: F2 low.
Phrases: "descriptive", "cataloging", "fishing expedition".

### mode-03-interdependent-aims
Cause: later aims collapse if the first aim's hypothesis fails.
Grid: F2 feasibility bullets low.
Phrases: "aims are contingent", "hinges on Aim 1", "aims are interdependent".

### mode-04-weak-sponsor-case
Cause: the sponsor's mentoring record or funding runway for this unbudgeted fellowship is thin or undocumented.
Grid: F3 gaps_flagged, trust language in F2 comments.
Phrases: "additional expertise or resources", "how the research will be funded", "sponsor's record of trainee outcomes".

### mode-05-generic-training-plan
Cause: the training plan is a course list rather than a gap analysis tied to this candidate's stated career goal.
Grid: F1 comments carry it.
Phrases: "list of activities", "not individualized", "generic training plan".

### mode-06-record-not-argued
Cause: the candidate's record is listed rather than argued as preparation and potential for the stated trajectory.
Grid: F1 lags F2 even when productivity is objectively fine.
Phrases: "potential for an independent research career is not well established", "record is not placed in context".

### mode-07-thin-preliminary-data
Cause: application filed pre-candidacy with preliminary data too thin to support the aims.
Grid: F2 risk bullets.
Phrases: "high risk", "has not advanced to candidacy", "ability to execute the methods is not demonstrated".

### mode-08-infeasible-timeline
Cause: the proposed scope does not fit the years remaining in the program.
Grid: F2 feasibility weakness.
Phrases: "overly ambitious", "cannot be completed in the time", "scope exceeds the training period".

### mode-09-rigor-gaps
Cause: required rigor elements are missing, such as power analysis, sex as a biological variable, or alternative interpretations.
Grid: itemized F2 weakness bullets, formulaic.
Phrases: "power analysis", "sex as a biological variable", "alternative interpretations are not addressed", "rigor of the prior research".

### mode-10-significance-restated
Cause: the significance section restates the field instead of arguing the gap this project fills.
Grid: F2 significance bullet, novelty unchallenged.
Phrases: "significance is not well developed", "restates the literature", "the gap is not articulated".

### mode-11-sponsor-candidate-contradiction
Cause: the sponsor statement and candidate statement contradict each other on goals or role division.
Grid: trust language drops across all items.
Phrases: "inconsistent with the sponsor's description", "statements do not agree", "role of the candidate is unclear across documents".

### mode-12-wrong-rubric-version
Cause: the application is written to the pre-2025 five-criterion format after January 25, 2025, scattering evidence where reviewers no longer look.
Grid: scores lower than content quality warrants, across factors.
Phrases: "information was hard to find", "material was missing from the expected section", "not organized around the current criteria".

### mode-13-wrong-ic-fit
Cause: the science is sound but sits at the margin of the assigned institute's mission or payline; the failure lives in targeting, not writing.
Grid: decent impact score, percentile just outside that IC's payline.
Phrases: "relevance to the mission", "better suited to another institute", plus the score pattern itself.

### mode-14-defensive-resubmission
Cause: the resubmission rebuts reviewers instead of incorporating them.
Grid: prior weaknesses reappear verbatim; introduction reads defensive.
Phrases: "previous concerns were not addressed", "response to prior review is argumentative", "weaknesses remain".
