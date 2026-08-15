# research-backed-writing-kit

Write like yourself. Research like a lab.

This is the pipeline behind [my essays](https://henrykernot.com): a set of Claude Code slash commands and a small SQLite knowledge graph that keep research-heavy writing honest. Each topic gets its own reference corpus. Claims trace to primary sources. And before anything ships, the corpus gets to disagree — the fact-check asks not "is every sentence cited?" but "is anything here contradicted?"

You write the prose. There is deliberately no "write the essay" command in here.

## What you get

- **Seven slash commands** for Claude Code: gated source capture, graph extraction, contradiction-checking, gap audits, quick corpus checks, register-aware rendering and a deterministic style linter.
- **A knowledge-graph schema** (`schema.sql`): refs → extracted claims / concepts / relations, versioned, full-text searchable. One SQLite file per topic. No embeddings, no services.
- **Agent context** (`CLAUDE.md`) so an AI assistant knows the rules of the house.
- **Style-guide templates** to bind your own voice, plus a Vale / cspell / markdownlint bundle (Australian English by default — swap it if you must).

## First five minutes

You need [Claude Code](https://claude.com/claude-code) and `sqlite3` (plus `python3`; the linter also wants `vale`, `cspell`, `markdownlint-cli2` and `prettier`).

```bash
git clone https://github.com/hk121992/research-backed-writing-kit.git
cd research-backed-writing-kit
scripts/doctor.sh                      # checks the toolchain
scripts/new-topic.sh my-first-topic    # folder layout + empty knowledge graph
claude                                 # open Claude Code here
```

Then, in Claude Code:

> /research-capture https://arxiv.org/abs/2303.10130

Capture proposes a candidate source list — nothing is fetched until you approve it. Then:

> /research-interpret

…extracts claims, concepts and relations into `my-first-topic/graph.sqlite`. Write your draft (that part is you), then:

> /research-factcheck my-first-topic/drafts/my-piece.md

…reports anything your own corpus contradicts, with the counter-source. `/research-gaps` tells you what a sceptical peer would ask that you haven't answered.

## The commands

| Command | What it does |
|---|---|
| `/research-capture <seed>` | Gated ingestion: propose candidates one hop out from a seed → you approve → fetch into `<topic>/references/` |
| `/research-interpret [ref_id]` | Extract concepts / claims / relations into the topic's graph |
| `/research-factcheck <draft>` | Contradiction detection against the corpus (read-only) |
| `/research-gaps [topic-or-draft]` | Coverage audit: missing canon, unaddressed counter-arguments, empirical gaps |
| `/research-quickcheck <claim>` | Fast "does the corpus say anything about this?" |
| `/research-tailor <draft> <target>` | Render a draft for a target (essay, newsletter, deck) with a citation output mode |
| `/research-lint <file.md>` | Deterministic style / format check (report-only) |

## The rules of the house

Three principles do most of the work:

1. **No silent capture.** Any command with side-effects gates for your approval first. Capture shows you the candidate list before fetching a thing.
2. **You own the prose and the angle.** Commands surface what the corpus says; they never auto-draft and never auto-remove your claims.
3. **Contradiction beats coverage.** The fact-check hunts claims your own corpus disputes, not sentences without footnotes. Opinion, analogy and narrative need no citation.

## Make it yours

- `STYLE-personal.template.md` — your voice: banned words, spelling conventions, the rules a linter can hold you to.
- `STYLE-research.template.md` — the research-register delta: citation output modes, source tiers, calibrated confidence.
- `.claude/commands/research-lint/` — the Vale `ProseAU` style and cspell dictionary; add your corpus authors' surnames as you capture them.
- A topic's `graph.sqlite` is committed by convention — your corpus is part of your repo.
- `scripts/new-topic.sh` creates topics inside this clone, so your corpus and the kit share one repo — fork it (or detach the remote) if you don't want upstream pulls mixing with your writing.

## Provenance

The research-integrity standards are adapted from [Feynman](https://github.com/getcompanion-ai/feynman), the open-source AI research agent (MIT), with one deliberate inversion: Feynman has a writer agent; this kit doesn't. The corpus-that-grows idea owes a debt to [Karpathy's LLM wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Full adaptation notes: [docs/provenance-feynman.md](docs/provenance-feynman.md).

How I use all of this in practice: [henrykernot.com/writing-with-ai](https://henrykernot.com/writing-with-ai/).

## Licence

MIT — see [LICENSE](LICENSE). Adapted third-party material is credited in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
