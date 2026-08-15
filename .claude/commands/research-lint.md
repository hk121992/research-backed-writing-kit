---
name: research-lint
description: Deterministic grammar + formatting + style check for any markdown file. Runs Vale (AU English, banned vocab, hedging, quote-inside-punct), cspell, markdownlint, and prettier. Emits a proposal report the operator reviews and applies selectively. Report-only by default; `--fix` enables prettier autofix. Not a register/voice/content check — that stays human.
---

# /research-lint

Deterministic prose and formatting check. The inversion of a semantic reviewer: only catches what rules can decide mechanically. Anything requiring judgement (voice, register, argument coherence, specificity, opening/closing shape) stays with the human editor.

**Status: Active** — defaults finalised 2026-07-01. Rules are heuristic and will emit false positives; the proposal report is meant to be filtered, not applied blindly.

## What this skill is — and what it is NOT

**It does:**
1. **Style-guide vocab.** Flags banned AI-tells (*delve, tapestry, leverage-as-verb, harness, paradigm shift*, etc. — [STYLE-personal.template.md §Banned Patterns](../../STYLE-personal.template.md)) and hedges / filler transitions / vague attribution.
2. **Australian English.** Flags American spellings (*organize → organise*, *behavior → behaviour*, *analyze → analyse*, *-er vs -re*, *traveling → travelling*, etc.) as a substitution rule.
3. **Punctuation conventions.** Enforces logical/Aussie quote-punctuation (period/comma **outside** closing quote by default — flags inside-placement for review). Also flags em-dash count > 3, double spaces, hyphen-in-numeric-range, non-AU date formats.
4. **Spelling.** cspell with en-GB dictionary plus a project wordlist (proper nouns from the corpus, pipeline terms).
5. **Markdown structure.** markdownlint-cli2 with standard rules (heading levels, list consistency, trailing whitespace). Line-length (MD013) disabled — prose paragraphs shouldn't be hard-wrapped.
6. **Whitespace hygiene.** prettier in `--check` mode flags formatting deltas without applying them.

**It does NOT:**
- Judge voice, register, opening, closing, or specificity — those remain human ([STYLE-research.template.md §Self-check](../../STYLE-research.template.md)).
- Resolve citations or fact-check — that's `/research-factcheck`.
- Rewrite prose or auto-fix content by default. Only prettier's whitespace fixes are applied, and only with an explicit `--fix` flag.
- Block publication. Report-only, non-gating.
- Replace the operator's own edit pass — the output is a proposal the operator tailors to the specific content.

## Args

    /research-lint <file.md> [--fix]

Works on any markdown file. Not coupled to this project — run it on drafts, web essays, LinkedIn posts, email templates, etc. `--fix` applies prettier autofix (safe-whitespace only); Vale/cspell/markdownlint findings stay report-only regardless.

## Behaviour

1. **Runner.** `.claude/commands/research-lint/scripts/run.sh <file.md> [--fix]` orchestrates:
    - Vale (with bundled `ProseAU` style + `Project` vocab)
    - cspell (bundled `cspell.json` + `project-words.txt`)
    - markdownlint-cli2 (bundled `markdownlint.jsonc`)
    - prettier (`--check` default; `--write` under `--fix`)
2. **Report.** Writes `<input-stem>.lint.md` as a sibling to the input file. Sections:
    - **Vale — style rules:** table of `Line | Severity | Rule | Message | Match`.
    - **cspell — spelling:** raw output; guidance on expanding the project wordlist.
    - **markdownlint — markdown structure:** rule-keyed findings.
    - **prettier — whitespace/formatting:** delta or autofix receipt.
    - **Status:** counts per check.
3. **Summary to stdout.** One-line per check, plus the path to the report.

## Constraints

- Read-only on input by default. `--fix` applies prettier whitespace fixes only; never rewrites prose.
- No network calls.
- All config is bundled in `.claude/commands/research-lint/`. No external `~/.vale.ini` or home-level configs consulted.
- Writes the `<input-stem>.lint.md` report beside the input, wherever the input lives — including outside this project. Under `--fix`, prettier also rewrites the input file itself in place; nothing else is touched.
- Rules are heuristic; the operator is the final judge.

## Assets

Config lives next to the command:

```
.claude/commands/research-lint/
├── vale/
│   ├── .vale.ini
│   └── styles/
│       ├── config/vocabularies/Project/
│       │   ├── accept.txt     # project-specific proper nouns & terms
│       │   └── reject.txt
│       └── ProseAU/
│           ├── BannedVocab.yml       # delve, tapestry, etc.
│           ├── LeverageVerb.yml      # leverage as verb
│           ├── Hedging.yml           # "it's worth noting that", etc.
│           ├── FillerTransitions.yml # Moreover, Furthermore, etc.
│           ├── VagueAttribution.yml  # "studies have shown", etc.
│           ├── USSpelling.yml        # American → Australian substitutions
│           ├── EmDashLimit.yml       # max 3 per doc
│           ├── QuotePunctInside.yml  # flags punctuation-inside-quote (default = outside)
│           ├── DoubleSpaces.yml
│           ├── NumericRangeDash.yml  # hyphen in ranges
│           └── DateFormat.yml        # US date format
├── cspell/
│   ├── cspell.json
│   └── project-words.txt
├── markdownlint.jsonc
└── scripts/
    └── run.sh
```

Two wordlists to keep in sync when a new proper noun becomes frequent:
- `vale/styles/config/vocabularies/Project/accept.txt` (Vale)
- `cspell/project-words.txt` (cspell)

## Settled defaults (finalised 2026-07-01)

- **Em-dash limit stays at 3** (STYLE-research.template.md C7: ≤ 2–3 per piece). A piece that earns more is the operator's call at review time, not the linter's.
- **`US date format` stays a suggestion, not an error** — avoids churn on dates inside quoted source text.
- **`QuotePunctInside` stays on at suggestion severity** — report-only, so its false positives on legitimate inside-placement are filtered by the operator rather than suppressed. Revisit with the multi-sentence / colon exception only if it gets noisy in practice.
- **`USSpelling` stays report-only even under `--fix`** — `--fix` applies prettier whitespace only; the linter never rewrites prose, AU spelling included.
- **`BannedVocab` stays a single list** — the research register's bans are the personal register's bans, only stronger (STYLE-research.template.md C2). No register split until a rule genuinely needs to differ.

## Out of scope

- Voice/register check → human editor, or a separate LLM-flavoured pass.
- Citation/fact check → `/research-factcheck`.
- Tailoring between output modes → `/research-tailor`.
- Grammar at the subject-verb / agreement level (would need LanguageTool; deferred to v2 if real gaps show).
