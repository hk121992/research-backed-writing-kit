---
name: research-tailor
description: Pivot a research draft into a different target (li-post, essay-pdf, deck-slide, web-essay, newsletter). Renders [ref_id] tokens into the target's citation output mode (inline hyperlinks / academic / hybrid). Selects the correct style guide for the target's register (research vs personal). Use when the operator says "make this a LinkedIn post" or "render this as a PDF essay" or "tailor for the deck appendix".
---

# /research-tailor

Register- and citation-aware draft tailoring. Implements the pipeline's **Tailor** motion.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## Args

    /research-tailor <draft-path> <target> [--mode inline|academic|hybrid]

Targets and their default citation output modes:

| Target | Default mode | Style guide |
|---|---|---|
| `li-post` | **inline** hyperlinks | `STYLE-personal.template.md` (personal register — explicit handoff) |
| `essay-pdf` | **academic** numbered refs | `STYLE-research.template.md` |
| `deck-slide` | **academic** (appendix) | `STYLE-research.template.md` |
| `web-essay` | **hybrid** (inline + reference list) | `STYLE-research.template.md` |
| `newsletter` | **inline** hyperlinks | `STYLE-research.template.md` |

Override default with `--mode <inline|academic|hybrid>`.

## Citation output modes (per `STYLE-research.template.md`)

| Mode | Where `[ref_id]` tokens become | Reference list | Typical use |
|---|---|---|---|
| **inline** | `[claim text](url)` — text linked to `refs.url` | None, or compact "Sources" block at end | LinkedIn, Substack, web essays, newsletters |
| **academic** | Superscripts or `[n]` markers | Full numbered refs at end (Author, Year, Title, Venue, URL) | PDF prints, deck appendix |
| **hybrid** | Inline hyperlinks in prose | Yes — full ref list at end | Long web essays where readers want both |

Rules:
- The draft is the single source of truth. `[ref_id]` never appears in a published deliverable.
- `refs.url` is required for `inline` and `hybrid` modes. If a primary has no public URL, flag it and offer: (a) archive link, (b) downgrade whole piece to `academic`, (c) leave the sentence uncited.
- Reference list, when present, is machine-generated from `refs` rows actually cited. Never hand-curated.

## Behaviour

1. **Parse draft** for `[ref_id]` tokens, `⟨UNCITED⟩` markers, structural sections.
2. **Resolve every `[ref_id]`** to a row in `refs`. If any miss → halt and refer operator to `/research-factcheck`.
3. **Compose outline + claim-map for the target.** Keep section structure proportional to target length. Map each section to its supporting `[ref_id]` tokens.
4. **GATE POINT — outline + claim-map approval (no silent capture).** Present:
    - Selected target, selected mode, selected style guide (declared explicitly — never silent register handoff)
    - Outline (section headings)
    - Claim-map (per section: which `[ref_id]` tokens carry which sections)
    - Any `refs.url` gaps (offer fallbacks)

   Wait for operator: `proceed` / `revise: <change>` / `stop`.

   **Do not draft prose before approval.**
5. **Render prose** into the target file. Apply selected style guide (cross-register handoff is loud — write the style guide's path into the output file's front-matter or a leading comment).
6. **Render citation tokens** per mode.
7. **Provenance sidecar.** Write `<output-path>.provenance.md` (Feynman pattern, see [`provenance-feynman.md`](../../docs/provenance-feynman.md) §5): input draft path, target, mode, style guide, `[ref_id]` tokens resolved, contradictions flagged at fact-check (cross-link if `/research-factcheck` outcome exists), claim-map presented at gate.
8. **Outcome file.** Lightweight summary returned to session: target rendered, mode, sidecar path, status.

## Constraints

- Cross-register handoffs are explicit. Tailoring to `li-post` activates the personal-voice style guide — declare in the output file's leading metadata.
- Preserve calibrated-confidence language (rule M5 in `STYLE-research.template.md`). Do not silently drop "evidence here is provisional" framings when shortening.
- Preserve `⟨UNCITED⟩` markers' intent — they survive into the rendered piece as deliberately uncited (no inline link, no superscript).
- Never modify the source draft.
- Never modify files outside this project.

## Settled defaults (finalised 2026-07-01)

- **Target list:** `li-post`, `essay-pdf`, `deck-slide`, `web-essay`, `newsletter` (as tabled). Add a new target by extending the table with a default mode + style guide; no code change needed.
- **Default mode per target** confirmed as tabled above. `li-post` stays **inline**, not hybrid — LI article footnote sections are unreliable; a compact end "Sources" block is the fallback when link density is high.
- **Tier-4/5 refs in `inline` mode link as normal** — the published piece never exposes the tier ladder to the reader; tier concerns live in `/research-factcheck`, not the rendered output.
- **Provenance sidecar:** `<output-path>.provenance.md`, next to the output (Feynman pattern; already the convention in `published/`).
- **`li-post` cross-register handoff is selective:** the personal-voice style guide governs voice, structure, and opening/closing; citation rendering still applies (inline hyperlinks) and `⟨UNCITED⟩` markers still suppress linking. Calibrated-confidence phrasing may relax to the personal register. The handoff is declared in the output's leading metadata, never silent.

## Out of scope

- Drafting from scratch → operator owns prose; this skill renders an existing draft into a target.
- Fact-checking → run `/research-factcheck` before tailoring.
- Capturing new refs → `/research-capture`.
