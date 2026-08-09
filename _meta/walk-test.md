# Walk test (structural gate)

Six items from ICM canon. Items 2, 3, 6 are mechanized in
`verify-gate.sh`. Items 1, 4, 5 need a memoryless reader and are run cold
by a fresh agent whose transcript is saved in `/verify-evidence.txt`.

| # | Item | How it is checked |
|---|------|-------------------|
| 1 | Orientation from the entry file in <= 2 reads | Cold read. A fresh agent reads `CLAUDE.md` only and answers: where am I, where do I go next, what does stage 03 need. |
| 2 | Every contract names exact inputs, job, output, human check | Mechanized: four section headers plus a Do NOT load line plus an audit table in every stage `CONTEXT.md`. |
| 3 | Status derivable by scanning `output/` | Satisfied by design and NOT mechanically checkable at submission: d.5 requires `output/` to ship holding only `.gitkeep`, so at rest every stage reads as not-run, which is the correct status. During a run, the presence of each stage's named output file is the status. The gate asserts the at-rest condition only. |
| 4 | No routing file carries payload | Cold read plus a mechanized proxy: root `CONTEXT.md` is links only, no rubric numbers, no mode names, no payline figures. |
| 5 | No fact stored twice | Mechanized proxy: canonical-source grep. Each failure-mode name, the rubric factor names, the payline threshold sentence, and the economics figures are authoritative in exactly one file. |
| 6 | Entry + one contract + its inputs lands in 2k-8k tokens | Mechanized, looped over ALL five stages, not sampled. Heuristic: bytes / 4. |
