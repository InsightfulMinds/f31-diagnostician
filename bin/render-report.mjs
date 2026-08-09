#!/usr/bin/env node
// render-report.mjs - render one diagnostician case run to a single self-contained report.html.
// Node 22, zero dependencies. Usage: node bin/render-report.mjs <case-run-dir>
// Expects <dir>/run/ with 02-extraction.json, 03-matches.json,
// optionally 04-verification.json, and 05-diagnosis.md OR 05-no-diagnosis.md.

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";

const dir = process.argv[2];
if (!dir) {
  console.error("usage: node bin/render-report.mjs <case-run-dir>");
  process.exit(1);
}
const caseDir = resolve(dir);
const runDir = join(caseDir, "run");
if (!existsSync(runDir)) {
  console.error(`no run/ directory under ${caseDir}`);
  process.exit(1);
}

const readJSON = (name) => {
  const p = join(runDir, name);
  return existsSync(p) ? JSON.parse(readFileSync(p, "utf8")) : null;
};
const readText = (name) => {
  const p = join(runDir, name);
  return existsSync(p) ? readFileSync(p, "utf8") : null;
};

const extraction = readJSON("02-extraction.json");
const matches = readJSON("03-matches.json");
const verification = readJSON("04-verification.json");
const diagnosisMd = readText("05-diagnosis.md");
const noDiagnosisMd = readText("05-no-diagnosis.md");

if (!extraction || !matches) {
  console.error("missing 02-extraction.json or 03-matches.json in run/");
  process.exit(1);
}
if (!diagnosisMd && !noDiagnosisMd) {
  console.error("missing stage 05 output (05-diagnosis.md or 05-no-diagnosis.md)");
  process.exit(1);
}
if (diagnosisMd && noDiagnosisMd) {
  console.error("both diagnosis and no-diagnosis present; contract says exactly one");
  process.exit(1);
}

const esc = (s) =>
  String(s ?? "").replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

const caseId = extraction.case_id ?? "unknown case";
const fp = extraction.face_page ?? {};
const label = extraction._label ?? null;
const refusal = Boolean(noDiagnosisMd);
const stage05 = diagnosisMd ?? noDiagnosisMd;

// Primary cause: the one bold mode id in 05-diagnosis.md.
let primaryCause = null;
if (diagnosisMd) {
  const m = diagnosisMd.match(/\*\*(mode-[0-9]+-[a-z0-9-]+)\*\*\s*[--]?\s*([^\n]*(?:\n(?![-*#\s]*$)(?![-*#])[^\n]*)*)/);
  if (m) {
    // Hard-wrapped markdown: join continuation lines, then keep the first full sentence.
    const joined = m[2].replace(/\s*\n\s*/g, " ").trim();
    const sentence = joined.match(/^.*?[.!?](?=\s|$)/);
    primaryCause = { mode: m[1], gloss: (sentence ? sentence[0] : joined).trim() };
  }
}

// Minimal markdown -> HTML for the stage-05 file (headings, bold, lists, paragraphs).
function mdToHtml(md) {
  const lines = md.split("\n");
  const out = [];
  let inList = false;
  const inline = (s) =>
    esc(s)
      .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
      .replace(/`([^`]+)`/g, "<code>$1</code>");
  let para = [];
  const flushPara = () => {
    if (para.length) { out.push(`<p>${inline(para.join(" "))}</p>`); para = []; }
  };
  const closeList = () => { if (inList) { out.push("</ol>"); inList = false; } };
  for (const raw of lines) {
    const line = raw.trimEnd();
    if (/^#{1,3}\s/.test(line)) {
      flushPara(); closeList();
      const level = line.match(/^#+/)[0].length;
      out.push(`<h${level + 1}>${inline(line.replace(/^#+\s*/, ""))}</h${level + 1}>`);
    } else if (/^\s*(?:[-*]|\d+\.)\s+/.test(line)) {
      flushPara();
      if (!inList) { out.push("<ol class=\"mdlist\">"); inList = true; }
      out.push(`<li>${inline(line.replace(/^\s*(?:[-*]|\d+\.)\s+/, ""))}</li>`);
    } else if (line.trim() === "") {
      flushPara(); closeList();
    } else {
      para.push(line.trim());
    }
  }
  flushPara(); closeList();
  return out.join("\n");
}

// Matched modes summary from 03-matches.json.
const modeCounts = new Map();
for (const m of matches.matches ?? []) {
  if (m.mode) modeCounts.set(m.mode, (modeCounts.get(m.mode) ?? 0) + 1);
}
const unmatchedCount = (matches.matches ?? []).filter((m) => m.unmatched).length;

// Evidence chain from verification (candidates) + extraction (quotes, excerpts).
const quoteById = new Map((extraction.critique_quotes ?? []).map((q) => [q.id, q]));
const excerptById = new Map((extraction.located_excerpts ?? []).map((x) => [x.id, x]));
const candidates = verification?.candidates ?? [];

function candidateBlock(c) {
  const isPrimary = primaryCause && c.mode === primaryCause.mode;
  const quotes = (c.quote_ids ?? [])
    .map((id) => quoteById.get(id))
    .filter(Boolean)
    .map((q) => `<blockquote><p>${esc(q.quote)}</p><footer>${esc(q.reviewer.replace("_", " "))}, ${esc(q.factor)}, ${esc(q.polarity)} <span class="qid">${esc(q.id)}</span></footer></blockquote>`)
    .join("");
  const excerpts = (c.excerpt_ids ?? [])
    .map((id) => excerptById.get(id))
    .filter(Boolean)
    .map((x) => `<blockquote class="app"><p>${esc(x.excerpt)}</p><footer>${esc(x.source)}, ${esc(x.section)} <span class="qid">${esc(x.id)}</span></footer></blockquote>`)
    .join("");
  return `<article class="cand ${isPrimary ? "primary" : ""}">
    <header><span class="mode">${esc(c.mode)}</span>${isPrimary ? '<span class="tag">Primary cause</span>' : ""}
      <span class="flags">${c.supported ? "supported" : "not supported"} · ${c.grid_supported ? `grid: ${esc(c.moved_cell ?? "moved")}` : "no moved cell"} · ${c.quote_count ?? (c.quote_ids ?? []).length} quote(s)</span></header>
    ${c.note ? `<p class="note">${esc(c.note)}</p>` : ""}
    ${quotes}${excerpts}
  </article>`;
}

// Validations table.
const validationRows = (verification?.validations ?? [])
  .map((v) => `<tr><td>${esc(v.value)}</td><td>${esc(v.type)}</td><td class="${v.is_valid ? "ok" : "bad"}">${v.is_valid ? "valid" : "invalid"}</td><td>${esc(v.message)}</td></tr>`)
  .join("");

const verdictBanner = refusal
  ? `<div class="verdict refusal">
       <span class="kicker">Verdict</span>
       <h2>No diagnosis</h2>
       <p>The evidence did not clear the stated threshold. The tool refused to name a cause rather than guess. The refusal, with the exact shortfall, is the output.</p>
     </div>`
  : `<div class="verdict cause">
       <span class="kicker">Verdict</span>
       <h2>Primary cause: <em>${esc(primaryCause?.mode ?? "named in diagnosis")}</em></h2>
       ${primaryCause?.gloss ? `<p>${esc(primaryCause.gloss)}</p>` : ""}
     </div>`;

const metaRows = [
  ["Case", caseId],
  ["Impact score", fp.impact_score?.raw],
  ["Percentile", fp.percentile?.raw],
  ["Payline", fp.payline],
  ["Outcome", fp.outcome],
  ["Items / warnings", `${matches.n_items ?? "?"} / ${matches.n_warnings ?? "?"}`],
]
  .filter(([, v]) => v !== undefined && v !== null)
  .map(([k, v]) => `<tr><td class="k">${esc(k)}</td><td>${esc(v)}</td></tr>`)
  .join("");

const modesList = modeCounts.size
  ? [...modeCounts.entries()].map(([m, n]) => `<li><span class="mode">${esc(m)}</span> matched by ${n} quote(s)</li>`).join("")
  : `<li>No failure mode matched any quote.</li>`;

const labelComment = label && label.includes("RECONSTRUCTED")
  ? `<!-- ${label} -->\n`
  : "";
const html = `${labelComment}<!DOCTYPE html>
${label ? `<!-- ${label.replace(/--+/g, "-")} -->\n` : ""}<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(caseId)} - F31 diagnostician report</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,600;9..144,700&family=Source+Sans+3:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
<style>
  :root { --navy:#1c2d5e; --navy-deep:#15234b; --gold:#e8a820; --gold-deep:#c78e12;
          --ink:#1d2333; --dim:#5a6376; --line:#e5e8ef; --wash:#f7f8fb; --white:#ffffff; }
  * { box-sizing:border-box; margin:0; }
  body { background:var(--white); color:var(--ink);
         font:17px/1.65 "Source Sans 3", -apple-system, Segoe UI, sans-serif; }
  h1,h2,h3,h4 { font-family:"Fraunces", Georgia, serif; color:var(--navy); letter-spacing:-0.01em; }
  main { max-width:820px; margin:0 auto; padding:0 1.4rem 5rem; }
  section { margin-top:3.2rem; }
  header.page { background:var(--navy-deep); border-bottom:3px solid var(--gold);
                padding:2.6rem 1.4rem 2.2rem; }
  header.page .inner { max-width:820px; margin:0 auto; }
  header.page h1 { color:#fff; font-size:clamp(1.6rem, 4vw, 2.3rem); }
  header.page p { color:#dbe2f2; margin-top:.4rem; }
  .kicker { display:inline-block; background:var(--gold); color:var(--navy-deep); font-weight:600;
            font-size:.76rem; letter-spacing:.08em; text-transform:uppercase; padding:.3rem .7rem; }
  .recon { background:var(--wash); border:1px solid var(--line); border-left:4px solid var(--gold);
           padding:.7rem 1rem; font-size:.88rem; color:var(--dim); margin-top:2rem; }
  .verdict { border:2px solid var(--navy); padding:1.4rem 1.5rem; margin-top:2.2rem; }
  .verdict h2 { margin:.6rem 0 .4rem; font-size:1.5rem; }
  .verdict h2 em { font-style:normal; color:var(--gold-deep); }
  .verdict.refusal { border-color:var(--gold-deep); background:#fdf8ec; }
  .verdict.refusal h2 { color:var(--gold-deep); }
  h2 { font-size:1.4rem; margin-bottom:.8rem; }
  table.meta { border-collapse:collapse; width:100%; max-width:34rem; font-size:.95rem; }
  table.meta td { border-top:1px solid var(--line); padding:.5rem .8rem; }
  table.meta td.k { font-weight:600; color:var(--navy); width:11rem; }
  ul.modes { list-style:none; padding:0; }
  ul.modes li { border-top:1px solid var(--line); padding:.55rem 0; }
  .mode { font-family:"Fraunces", serif; font-weight:700; color:var(--navy); }
  .cand { border:2px solid var(--line); padding:1.1rem 1.2rem; margin-top:1.1rem; border-radius:8px; }
  .cand.primary { border-color:var(--gold-deep); background:#fdf8ec; }
  .cand header { display:flex; flex-wrap:wrap; gap:.6rem; align-items:baseline; }
  .cand .tag { background:var(--gold); color:var(--navy-deep); font-weight:600; font-size:.74rem;
               text-transform:uppercase; letter-spacing:.07em; padding:.2rem .55rem; }
  .cand .flags { color:var(--dim); font-size:.85rem; }
  .cand .note { color:var(--dim); font-size:.92rem; margin-top:.5rem; }
  blockquote { border-left:3px solid var(--navy); margin:.8rem 0 0; padding:.4rem .9rem; }
  blockquote.app { border-left-color:var(--gold-deep); background:var(--wash); }
  blockquote footer { color:var(--dim); font-size:.82rem; margin-top:.25rem; }
  .qid { font-family:monospace; font-size:.78rem; color:var(--gold-deep); }
  table.vals { border-collapse:collapse; width:100%; font-size:.88rem; margin-top:.8rem; }
  table.vals th { text-align:left; background:var(--navy); color:#fff; padding:.45rem .7rem;
                  font-weight:600; font-size:.8rem; letter-spacing:.04em; text-transform:uppercase; }
  table.vals td { border-top:1px solid var(--line); padding:.4rem .7rem; }
  td.ok { color:#1a7a3a; font-weight:600; }  td.bad { color:#b3261e; font-weight:600; }
  .stage05 { border:1px solid var(--line); border-radius:8px; padding:1.3rem 1.5rem; background:var(--wash); }
  .stage05 h2,.stage05 h3 { margin-top:1rem; font-size:1.15rem; }
  .stage05 h2:first-child { margin-top:0; }
  .stage05 p { margin-top:.7rem; font-size:.96rem; }
  .stage05 ol.mdlist { margin:.6rem 0 0 1.3rem; }
  .stage05 li { margin:.35rem 0; font-size:.96rem; }
  code { background:var(--line); padding:.05rem .3rem; border-radius:4px; font-size:.86em; }
  footer.page { border-top:1px solid var(--line); margin-top:3.5rem; padding-top:1rem;
                color:var(--dim); font-size:.85rem; }
</style>
</head>
<body>
<header class="page"><div class="inner">
  <span class="kicker">F31 diagnostician - case report</span>
  <h1>${esc(caseId)}</h1>
  <p>${refusal ? "Refusal: evidence below threshold, no cause named." : "One primary cause, with the evidence chain shown."}</p>
</div></header>
<main>
  ${label ? `<div class="recon">${esc(label)}</div>` : ""}
  ${verdictBanner}

  <section>
    <h2>Case metadata</h2>
    <table class="meta">${metaRows}</table>
  </section>

  <section>
    <h2>Matched failure modes</h2>
    <p class="dim">${esc(matches.grid_reading ?? "")}</p>
    <ul class="modes">${modesList}
      ${unmatchedCount ? `<li>${unmatchedCount} quote(s) unmatched - recorded as warnings, never forced onto a near mode.</li>` : ""}
    </ul>
  </section>

  ${candidates.length ? `<section>
    <h2>Evidence chain</h2>
    ${candidates.map(candidateBlock).join("\n")}
  </section>` : ""}

  ${validationRows ? `<section>
    <h2>Range validations</h2>
    <table class="vals"><thead><tr><th>Value</th><th>Type</th><th>Result</th><th>Message</th></tr></thead>
    <tbody>${validationRows}</tbody></table>
  </section>` : ""}

  <section>
    <h2>${refusal ? "Refusal, in full" : "Diagnosis, in full"}</h2>
    <div class="stage05">${mdToHtml(stage05)}</div>
  </section>

  <footer class="page">Generated by bin/render-report.mjs from the stage outputs in run/. The pipeline stops after stage 05; this page renders, it does not decide.</footer>
</main>
</body>
</html>
`;

const outPath = join(caseDir, "report.html");
writeFileSync(outPath, html);
console.log(`wrote ${outPath} (${html.length} bytes, ${refusal ? "refusal" : `primary cause ${primaryCause?.mode}`})`);
