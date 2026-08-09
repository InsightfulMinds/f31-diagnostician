# Stage audit-table template

Every stage CONTEXT.md embeds an audit table using this header, with
ONLY that stage's own rows. Run the checks after the Process steps and
before writing anything to `output/`. Each check must be unambiguous:
a reader can answer pass or fail without judgment.

| Check | Pass Condition |
|-------|----------------|
| (stage-specific) | (stage-specific) |

Rules:
- The table lives in the stage contract, colocated with the work.
- This template is the only shared copy. Stages link here and never
  restate these rules.
