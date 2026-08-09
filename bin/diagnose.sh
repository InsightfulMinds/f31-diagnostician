#!/usr/bin/env bash
# diagnose.sh - contract-walker for the F31 diagnostician pipeline.
# Usage: bin/diagnose.sh <input-dir>
#   <input-dir> must contain the two case documents:
#     application.(md|txt|pdf-extracted text) and summary-statement.(md|txt)
# Walks stages 01→05 per each stage's CONTEXT.md contract. Stages 01-05 are
# LLM work: if the `claude` CLI is on PATH each stage is executed with
# `claude -p "<stage prompt>"`; otherwise this script prints exactly what an
# agent must do per stage and exits 2. Afterwards it renders report.html.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT_DIR="${1:?usage: bin/diagnose.sh <input-dir with application + summary-statement>}"
INPUT_DIR="$(cd "$INPUT_DIR" && pwd)"

APP=$(find "$INPUT_DIR" -maxdepth 1 -iname 'application*' | head -1)
SS=$(find "$INPUT_DIR" -maxdepth 1 -iname 'summary-statement*' | head -1)
[ -z "$APP" ] || [ -z "$SS" ] && {
  echo "BLOCKED: need both documents in $INPUT_DIR (application*, summary-statement*)." >&2
  echo "The pipeline stops on one document (stage 01 contract, process step 2)." >&2
  exit 1
}

STAGES=(01_intake 02_extract 03_match 04_verify 05_diagnose)

stage_prompt() {
  local stage="$1"
  cat <<EOF
You are inside the ICM Pipeline workspace at $ROOT.
Read ONLY $ROOT/stages/$stage/CONTEXT.md and the exact inputs it names
(its "Do NOT load" line is binding). The case documents for this run are:
  application:       $APP
  summary statement: $SS
Execute the stage's numbered Process exactly, write its Outputs into
$ROOT/stages/$stage/output/, and fill the audit table per
$ROOT/_shared/schema/audit-table.md. If the contract says stop, stop.
EOF
}

if ! command -v claude >/dev/null 2>&1; then
  echo "The 'claude' CLI is not available. The five stages are LLM work run"
  echo "by contract. An agent must do the following, in order:"
  echo
  for s in "${STAGES[@]}"; do
    echo "--- stage $s ---"
    stage_prompt "$s"
    echo
  done
  echo "Then render: node $ROOT/bin/render-report.mjs <case-run-dir>"
  exit 2
fi

for s in "${STAGES[@]}"; do
  echo "== stage $s =="
  claude -p "$(stage_prompt "$s")"
  # Contract stop conditions: blocked intake, or a stage 05 output, end the walk.
  if [ "$s" = "01_intake" ] && [ -f "$ROOT/stages/01_intake/output/blocked.md" ]; then
    echo "Stage 01 wrote blocked.md. Stopping per contract."
    exit 1
  fi
done

# Collect the run into the input dir so the renderer has one case directory.
RUN="$INPUT_DIR/run"
mkdir -p "$RUN"
cp "$ROOT/stages/02_extract/output/extraction.json"   "$RUN/02-extraction.json"
cp "$ROOT/stages/03_match/output/matches.json"        "$RUN/03-matches.json"
[ -f "$ROOT/stages/04_verify/output/verification.json" ] && \
  cp "$ROOT/stages/04_verify/output/verification.json" "$RUN/04-verification.json"
if [ -f "$ROOT/stages/05_diagnose/output/diagnosis.md" ]; then
  cp "$ROOT/stages/05_diagnose/output/diagnosis.md" "$RUN/05-diagnosis.md"
elif [ -f "$ROOT/stages/05_diagnose/output/no-diagnosis.md" ]; then
  cp "$ROOT/stages/05_diagnose/output/no-diagnosis.md" "$RUN/05-no-diagnosis.md"
else
  echo "Stage 05 produced neither diagnosis.md nor no-diagnosis.md." >&2
  exit 1
fi

node "$ROOT/bin/render-report.mjs" "$INPUT_DIR"
echo "Done: $INPUT_DIR/report.html"
