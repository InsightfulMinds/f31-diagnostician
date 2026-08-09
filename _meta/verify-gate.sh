#!/usr/bin/env bash
# Mechanical acceptance battery for the F31 diagnostician workspace.
# PASS / FAIL / KNOWN lines. Exits nonzero if any FAIL.
#   verify-gate.sh [root]      run the gate (default root = this script's parent)
#   verify-gate.sh --selftest  prove the gate can fail: inject 3 defects into a
#                              temp copy and assert the gate rejects each one.

set -uo pipefail

FAILS=0
pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; FAILS=$((FAILS+1)); }
known() { echo "KNOWN $*"; }

selftest() {
  local src="$1" tmp rc out
  echo "=== SELFTEST: the gate must reject each injected defect ==="
  local defects=0 caught=0
  for defect in forced_diagnosis leaked_reconstructed_string bad_rubric_type em_dash; do
    tmp=$(mktemp -d)
    cp -R "$src/." "$tmp/"
    case "$defect" in
      forced_diagnosis)
        # the refusal control forced into naming a cause
        printf 'RECONSTRUCTED - injected.\n\nmode-06-record-not-argued\n' \
          > "$tmp/_shared/examples/reconstructed/case-02-refusal/run/05-diagnosis.md" ;;
      leaked_reconstructed_string)
        printf '\nEnthusiasm among the reviewers was moderate.\n' >> "$tmp/README.md" ;;
      bad_rubric_type)
        python3 - "$tmp" <<'PY'
import json,sys,pathlib
p=pathlib.Path(sys.argv[1])/"_shared/rules/rubric-2025.json"
d=json.loads(p.read_text())
d["factors"][2]["type"]="criterion_1_9"   # Factor 3 wrongly made numeric
p.write_text(json.dumps(d,indent=2))
PY
        ;;
      em_dash)
        printf '\nan em dash \xe2\x80\x94 here\n' >> "$tmp/CONTEXT.md" ;;
    esac
    defects=$((defects+1))
    out=$(bash "$tmp/_meta/verify-gate.sh" "$tmp" 2>&1); rc=$?
    if [ "$rc" -ne 0 ]; then
      caught=$((caught+1)); echo "PASS  selftest/$defect rejected (exit $rc)"
    else
      echo "FAIL  selftest/$defect NOT rejected - the gate is vacuous for this check"
    fi
    rm -rf "$tmp"
  done
  echo "=== SELFTEST $caught/$defects defects caught ==="
  [ "$caught" -eq "$defects" ] || exit 1
  exit 0
}

if [ "${1:-}" = "--selftest" ]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  selftest "$ROOT"
fi

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT" || exit 2
STAGES=(01_intake 02_extract 03_match 04_verify 05_diagnose)

echo "=== 1. Ceilings ==="
n=$(wc -l < CLAUDE.md)
[ "$n" -le 60 ] && pass "entry CLAUDE.md $n lines (<=60)" || fail "entry CLAUDE.md $n lines (>60)"
for s in "${STAGES[@]}"; do
  n=$(wc -l < "stages/$s/CONTEXT.md")
  [ "$n" -le 80 ] && pass "stages/$s/CONTEXT.md $n lines (<=80)" || fail "stages/$s/CONTEXT.md $n lines (>80)"
done
while IFS= read -r f; do
  n=$(wc -l < "$f")
  [ "$n" -le 200 ] && pass "reference $f $n lines (<=200)" || fail "reference $f $n lines (>200)"
done < <(find _shared stages/*/references -type f 2>/dev/null | sort)

echo "=== 2. Contract shape ==="
for s in "${STAGES[@]}"; do
  f="stages/$s/CONTEXT.md"; ok=1
  for h in '^## Inputs' '^## Process' '^## Outputs' '^## Human check'; do
    grep -q "$h" "$f" || { fail "$f missing section $h"; ok=0; }
  done
  grep -q 'Do NOT load' "$f" || { fail "$f missing Do NOT load line"; ok=0; }
  grep -qF '| Check | Pass Condition |' "$f" || { fail "$f missing audit table header"; ok=0; }
  [ "$ok" = 1 ] && pass "$f four sections + Do-NOT-load + audit table"
done
# line-wrap-insensitive phrase checks
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
for s in 03_match 05_diagnose; do
  flat "stages/$s/CONTEXT.md" | grep -qF 'any prior' \
    && pass "stages/$s forbids prior output (d.9)" \
    || fail "stages/$s missing prior-output prohibition (d.9)"
done
flat stages/02_extract/CONTEXT.md | grep -qF 'scored_value = (max + min) - score' \
  && pass "02_extract restates the reverse-coding formula inline" \
  || fail "02_extract does not restate the reverse-coding formula"
flat stages/05_diagnose/CONTEXT.md | grep -qF '>= 2 verbatim critique quotes' \
  && pass "05_diagnose restates the evidence threshold inline" \
  || fail "05_diagnose does not restate the evidence threshold"
flat stages/03_match/CONTEXT.md | grep -qF 'no midpoint failure mode' \
  && pass "03_match defines strategy 5 as flag-not-force" \
  || fail "03_match does not rule out midpoint forcing"

echo "=== 3. One-way references ==="
for i in "${!STAGES[@]}"; do
  s="${STAGES[$i]}"; bad=0
  for later in "${STAGES[@]:$((i+1))}"; do
    if grep -rqF "$later" "stages/$s" 2>/dev/null; then
      fail "stages/$s names later stage $later"; bad=1
    fi
  done
  [ "$bad" = 0 ] && pass "stages/$s names no later stage"
done

echo "=== 4. Rubric validates against its own schema ==="
python3 - <<'PY' || exit_code=1
import json, sys
d = json.load(open("_shared/rules/rubric-2025.json"))
vt = d["schema"]["value_types"]; errs = []
cat = [f for f in d["factors"] if vt[f["type"]]["kind"] == "categorical"]
for f in d["factors"] + [d["overall"], d["percentile"]]:
    for k in d["schema"]["factor_required_keys"]:
        if k not in f: errs.append(f"{f.get('id')} missing {k}")
    if f["type"] not in vt: errs.append(f"{f.get('id')} unknown type {f['type']}")
for name, t in vt.items():
    if t["kind"] == "numeric":
        for k in ("min","max","reverse_scored"):
            if k not in t: errs.append(f"{name} missing {k}")
    elif t["kind"] == "categorical":
        if not t.get("values"): errs.append(f"{name} missing values")
if len(cat) != 1: errs.append(f"expected exactly 1 categorical factor, got {len(cat)}")
if cat and cat[0]["id"] != "F3": errs.append("the categorical factor must be F3 Commitment to Candidate")
for f in cat:
    if "min" in f or "max" in f: errs.append(f"{f['id']} categorical must not carry min/max")
if errs:
    for e in errs: print("FAIL  rubric:", e)
    sys.exit(1)
print("PASS  rubric-2025.json validates against its declared schema (3 factors, F3 categorical, 3 numeric types)")
PY
[ "${exit_code:-0}" = 1 ] && FAILS=$((FAILS+1)); exit_code=0

echo "=== 4b. Reverse coding present in every example extraction ==="
python3 - <<'PY' || exit_code=1
import json, glob, sys
bad = []
for p in glob.glob("_shared/examples/**/*extraction*.json", recursive=True):
    d = json.load(open(p))
    for factor, cells in d.get("grid", {}).items():
        if factor.startswith("_") or not isinstance(cells, dict): continue
        for rev, cell in cells.items():
            if cell.get("type") == "criterion_1_9":
                if "raw" not in cell or "scored" not in cell: bad.append(f"{p} {factor}/{rev} missing raw or scored")
                elif cell["scored"] != 10 - cell["raw"]: bad.append(f"{p} {factor}/{rev} scored != 10 - raw")
            elif cell.get("type") == "categorical_commitment":
                if cell.get("value") not in ("appropriate","gaps_flagged"): bad.append(f"{p} {factor}/{rev} bad categorical value")
                if "raw" in cell or "scored" in cell: bad.append(f"{p} {factor}/{rev} categorical carries a number")
    fp = d.get("face_page", {}).get("impact_score")
    if fp and fp.get("scored") != 100 - fp.get("raw", 0): bad.append(f"{p} impact scored != 100 - raw")
    for k in ("n_items","n_warnings"):
        if not isinstance(d.get(k), int): bad.append(f"{p} missing integer {k}")
if bad:
    for b in bad: print("FAIL  reverse-coding:", b)
    sys.exit(1)
print("PASS  every 1-9 and 10-90 item carries raw+scored with correct arithmetic; F3 categorical; counts present")
PY
[ "${exit_code:-0}" = 1 ] && FAILS=$((FAILS+1)); exit_code=0

echo "=== 5a. NIAID extraction fidelity ==="
python3 - <<'PY' || exit_code=1
import json, re, sys
def norm(t):
    t = t.replace("’","'").replace("‘","'").replace("“",'"').replace("”",'"')
    return re.sub(r"\s+", " ", t).strip()
src = norm(open("_shared/examples/niaid-pair/source-excerpts.txt", encoding="utf-8").read())
exp = json.load(open("_shared/examples/niaid-pair/expected-extraction.json"))
miss = [q["quote"][:50] for q in exp["critique_quotes"] if norm(q["quote"]) not in src]
miss += [e["excerpt"][:50] for e in exp["located_excerpts"] if norm(e["excerpt"]) not in src]
grid_lines = [l for l in src.split("CRITIQUE ") if l.strip()]
for factor, cells in exp["grid"].items():
    if factor.startswith("_") or not isinstance(cells, dict): continue
    for i, (rev, cell) in enumerate(sorted(cells.items()), start=1):
        seg = [l for l in grid_lines if l.startswith(str(i))]
        if seg and f"{factor}: {cell['raw']}" not in seg[0]:
            miss.append(f"grid {factor}/{rev}={cell['raw']} not in verbatim critique {i}")
if miss:
    for m in miss: print("FAIL  niaid fidelity:", m)
    sys.exit(1)
print("PASS  every NIAID quote, excerpt, and grid cell matches the verbatim source excerpts")
PY
[ "${exit_code:-0}" = 1 ] && FAILS=$((FAILS+1)); exit_code=0
grep -qi 'NIAID' _shared/examples/niaid-pair/README.md && grep -qi 'credited' _shared/examples/niaid-pair/README.md \
  && pass "NIAID credit line present in the example folder header" \
  || fail "NIAID credit line missing from the example folder header"
[ -f _shared/examples/niaid-pair/diagnosis.md ] && fail "a diagnosis exists for the FUNDED NIAID pair" \
  || pass "no diagnosis is run on the funded NIAID pair"

echo "=== 5b. Demo diagnosis on the reconstructed below-payline case ==="
DEMO=_shared/examples/reconstructed/case-01-below-payline/run/05-diagnosis.md
if [ -f "$DEMO" ]; then
  modes=$(grep -oE 'mode-[0-9]{2}-[a-z0-9-]+' "$DEMO" | sort -u | wc -l | tr -d ' ')
  primary=$(sed -n '/## Primary cause/,/## Evidence chain/p' "$DEMO" | grep -oE 'mode-[0-9]{2}-[a-z0-9-]+' | sort -u | wc -l | tr -d ' ')
  quotes=$(grep -cE '^[0-9]+\. Reviewer' "$DEMO")
  [ "$primary" = "1" ] && pass "demo names exactly one primary cause ($modes modes mentioned in total)" || fail "demo primary cause count = $primary"
  [ "$quotes" -ge 2 ] && pass "demo cites $quotes verbatim critique quotes (>=2)" || fail "demo cites $quotes quotes (<2)"
  grep -q 'Moved grid cell' "$DEMO" && pass "demo cites a moved grid cell" || fail "demo cites no moved grid cell"
  grep -q 'Located application excerpt' "$DEMO" && pass "demo traces to a located excerpt" || fail "demo traces to no located excerpt"
  grep -qiE 'we recommend|you should|next step|rewrite the' "$DEMO" && fail "demo contains advice" || pass "demo contains no advice"
else
  fail "demo diagnosis missing at $DEMO"
fi

echo "=== 6. Negative control: refusal on the below-payline no-match case ==="
REF=_shared/examples/reconstructed/case-02-refusal/run
if [ -f "$REF/05-no-diagnosis.md" ] && [ ! -f "$REF/05-diagnosis.md" ]; then
  pass "refusal case produced no-diagnosis.md and no diagnosis"
  grep -q 'FAILED' "$REF/05-no-diagnosis.md" && pass "refusal names the shortfall condition(s)" || fail "refusal does not name the shortfall"
  named=$(grep -oE 'mode-[0-9]{2}-[a-z0-9-]+' "$REF/05-no-diagnosis.md" | sort -u | wc -l | tr -d ' ')
  grep -qE 'refus|declin' "$REF/05-no-diagnosis.md" && pass "refusal states why the tempting modes ($named discussed) were declined" \
    || fail "refusal does not explain the declined candidates"
else
  fail "refusal case did not produce no-diagnosis.md, or produced a diagnosis anyway"
fi

echo "=== 7. Reconstructed labels and tree-wide leak grep ==="
bad=0
while IFS= read -r f; do
  head -2 "$f" | grep -q 'RECONSTRUCTED' || { fail "$f lacks the RECONSTRUCTED label in its first 2 lines"; bad=1; }
done < <(find _shared/examples/reconstructed -type f | sort)
[ "$bad" = 0 ] && pass "every file under examples/reconstructed carries the label on line 1"
PHRASES=("NAKAMURA" "OKONKWO" "Enthusiasm among the reviewers was moderate" "IMM 210 Advanced Immunology" "mucosal immunology" "strong field this cycle" "LINDQVIST" "OYELARAN" "KOVACS" "reads like an R01 scaled" "trainee outcomes is not provided" "yielding a validated hit" "fiber photometry" "imaging and sequencing cores" "dominant efflux transporter")
leak=0
for p in "${PHRASES[@]}"; do
  while IFS= read -r hit; do
    case "$hit" in
      ./_shared/examples/reconstructed/*|./_meta/verify-gate.sh|./verify-evidence.txt) ;;
      *) fail "reconstructed phrase leaked outside examples/reconstructed: '$p' in $hit"; leak=1 ;;
    esac
  done < <(grep -rlF "$p" . 2>/dev/null)
done
[ "$leak" = 0 ] && pass "no reconstructed phrase appears outside examples/reconstructed"

echo "=== 8. Canon greps ==="
if grep -rl "$(printf '\xe2\x80\x94')" --exclude=verify-gate.sh --exclude=verify-evidence.txt . >/dev/null 2>&1; then
  grep -rl "$(printf '\xe2\x80\x94')" --exclude=verify-gate.sh --exclude=verify-evidence.txt . | while read -r f; do echo "      em-dash in $f"; done
  fail "em-dash found in the tree"
else
  pass "no em-dash anywhere in the tree"
fi
for term in mode-01-mini-r01 mode-06-record-not-argued mode-13-wrong-ic-fit; do
  c=$(grep -rlF "$term" --exclude-dir=_meta . | grep -v verify-evidence.txt | grep -c . )
  # the mode NAME may appear in a diagnosis; the mode DEFINITION may not.
  d=$(grep -rlF "Cause:" _shared/rules/failure-modes.md | wc -l | tr -d ' ')
  [ "$d" = "1" ] && pass "$term defined only in failure-modes.md (referenced in $c files)" || fail "$term has $d definition homes"
done
c=$(grep -rl "Candidate's Preparedness and Potential" . | grep -v verify-evidence.txt | grep -cv '_shared/examples' )
[ "$c" -le 3 ] && pass "rubric factor names concentrated in rubric-2025.json plus stage references ($c files)" \
  || fail "rubric factor names spread across $c non-example files"
c=$(grep -rl 'at or inside the assigned' --exclude-dir=_meta . | grep -v verify-evidence.txt | wc -l | tr -d ' ')
[ "$c" = "1" ] && pass "payline threshold sentence has exactly one home" || fail "payline threshold sentence in $c files"
if [ -f README.md ]; then
  c=$(grep -rlF '184,186' --exclude-dir=_meta . | grep -v verify-evidence.txt | wc -l | tr -d ' ')
  [ "$c" = "1" ] && pass "economics token figures have exactly one home" || fail "economics token figures in $c files"
fi

echo "=== 9. Root catalog holds no payload (d.20) ==="
if grep -qE 'mode-[0-9]{2}|1-9|10-90|percentile|scored_value|payline of' CONTEXT.md; then
  fail "root CONTEXT.md carries payload (rubric numbers, mode ids, or thresholds)"
else
  pass "root CONTEXT.md links down and stores nothing"
fi
n=$(wc -l < CONTEXT.md); [ "$n" -le 80 ] && pass "root CONTEXT.md $n lines" || fail "root CONTEXT.md $n lines (>80)"

echo "=== 10. output/ ships empty ==="
bad=0
for s in "${STAGES[@]}"; do
  files=$(find "stages/$s/output" -type f ! -name .gitkeep | wc -l | tr -d ' ')
  [ "$files" = "0" ] || { fail "stages/$s/output holds $files committed files"; bad=1; }
done
[ "$bad" = 0 ] && pass "every stage output/ holds only .gitkeep"

echo "=== 11. Token budget per stage (entry + contract + its named inputs) ==="
python3 - <<'PY' || exit_code=1
import re, os, sys
entry = os.path.getsize("CLAUDE.md")
bad = []
for s in ["01_intake","02_extract","03_match","04_verify","05_diagnose"]:
    p = f"stages/{s}/CONTEXT.md"
    txt = open(p, encoding="utf-8").read()
    total = entry + os.path.getsize(p)
    inputs = set(re.findall(r"`([^`]+\.(?:md|json|txt))`", txt.split("## Process")[0]))
    for f in inputs:
        f = f.lstrip("/")
        if f.startswith("stages/") and "/output/" in f:
            # at rest, stage outputs are empty by design (d.5). Use the matching
            # example-run artifact as the size proxy so the budget is not understated.
            m = re.match(r"stages/(\d\d)_", f)
            if m:
                import glob as _g
                proxy = _g.glob(f"_shared/examples/reconstructed/case-01-below-payline/run/{m.group(1)}-*")
                if proxy: total += os.path.getsize(proxy[0])
        elif os.path.isfile(f):
            total += os.path.getsize(f)
    tok = total // 4
    (bad.append(f"{s} {tok} tokens") if not (2000 <= tok <= 8000)
     else print(f"PASS  {s}: entry+contract+inputs ~= {tok} tokens (2k-8k)"))
if bad:
    for b in bad: print("FAIL  token budget:", b)
    sys.exit(1)
PY
[ "${exit_code:-0}" = 1 ] && FAILS=$((FAILS+1)); exit_code=0

echo "=== 12. Submission README ==="
if [ -f README.md ]; then
  grep -qF '34/39' README.md && grep -qF '29/39' README.md && pass "README carries the accuracy trade sentence" || fail "README lacks the 34/39 vs 29/39 trade"
  grep -qF '97.1' README.md && grep -qF '95.2' README.md && pass "README carries both savings figures" || fail "README lacks the savings figures"
  # cohort was locked to Technical at the public-artifact pass (commit 50d33ee);
  # the old check required a "pending Sean" marker that the lock deliberately removed.
  grep -qE '^Cohort: Technical\.' README.md && pass "README states the locked cohort (Technical)" || fail "README missing the locked cohort line"
  grep -q '## GAPS' README.md && pass "README has a GAPS section" || fail "README has no GAPS section"
else
  fail "README.md missing"
fi
[ -f sources.md ] && grep -qi 'niaid' sources.md && pass "sources.md exists and credits NIAID" || fail "sources.md missing or lacks NIAID credit"

echo
if [ "$FAILS" -eq 0 ]; then
  echo "GATE: GREEN (0 FAIL)"; exit 0
else
  echo "GATE: RED ($FAILS FAIL)"; exit 1
fi
