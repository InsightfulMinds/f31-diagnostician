RECONSTRUCTED - every file under this folder is reconstructed from real rubric structure and published reviewer-critique guidance patterns. None of it is real reviewer language from a real application, and none of it may be quoted anywhere outside this folder.

Why these exist: public NIH sample pairs are funded exemplars. Real
below-payline full applications with their summary statements are scarce
in public. Rather than diagnose a funded application (which would force
the tool to invent a failure), the demo and the refusal control both run
on reconstructed cases whose provenance is stated on line 1 of every file.

- `case-01-below-payline/` unfunded, critique language that DOES map to
  the table. Produces one primary cause. This is the demo diagnosis.
- `case-02-refusal/` unfunded, critique language that maps to NOTHING in
  the table. Must produce `no-diagnosis.md`. This is the negative control,
  and it is the case a tool is tempted to force.

`verify-gate.sh` greps the whole tree for distinctive strings from these
cases. A hit outside this folder is a FAIL.
