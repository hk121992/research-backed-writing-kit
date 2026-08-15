# Personal Style Guide

> **Template.** This is your personal-voice guide — the base layer every register in this kit builds on (`STYLE-research.template.md` is the research-register delta applied on top of it). The deterministic linter (`/research-lint`) enforces the mechanical subset of what's below — banned vocabulary, hedging, filler transitions, vague attribution, spelling, date format, dash and quote conventions — via the bundled Vale `ProseAU` style and cspell config. Everything else is judgement. Edit the vocabulary lists and conventions to taste, fill in the `<placeholders>`, and keep the guide and the lint config in agreement.

Instructions for you — and for any agent drafting under your name. Covers voice, banned patterns, English conventions, and the pre-submit self-check.

---

## Your Voice

Fill these in. They are the first thing an agent should read before drafting in your name — pull from real pieces you've written, not intentions.

- **Three writers whose registers you admire, and the move you take from each:** `<writer — move; writer — move; writer — move>`
- **Three moves your writing actually makes:** `<e.g. opens mid-thought with no scene-setting; analogy carries the argument; short fragments between longer analytical sentences>`
- **Three things your writing never does:** `<e.g. credential-leading; hedge stacking; passive voice for agency; thesis restatement at the end>`
- **One analogy, example, or honest admission you own** — agents should reuse it rather than invent generic ones: `<...>`

---

## Banned Patterns

These patterns are characteristic of generic AI output. Do not produce them. The bundled `ProseAU` lint rules should track this table — when you edit a row, update the matching rule.

### Never use

| # | Pattern | Examples | What to do instead |
|---|---------|----------|--------------------|
| 1 | **Uniform sentence length** | Every sentence 15-25 words, no fragments, no long complex sentences | Vary deliberately. Use three-word fragments between longer analytical sentences. |
| 2 | **Hedge phrases** | "It's worth noting that", "It's important to consider", "One might argue that" | Commit to the position. State it directly. |
| 3 | **Filler transitions** | "Moreover", "Furthermore", "Additionally", "That being said" | Drop them entirely. If the next paragraph doesn't follow without a transition word, restructure — don't bridge with filler. |
| 4 | **Overrepresented AI vocabulary** | "Delve", "tapestry", "landscape", "nuanced", "multifaceted", "leverage" (as verb), "harness", "paradigm shift", "at its core" | Use the word you would actually say in conversation. These words are banned. |
| 5 | **Artificial balance** | "On one hand... on the other hand..." for every claim, both sides given equal weight | Have opinions. State the position. Acknowledge a counter-argument briefly if warranted, then move on. |
| 6 | **Generic metaphors** | "Navigate the landscape", "unlock the potential", "bridge the gap" | Use specific, original analogies grounded in your actual experience (see §Your Voice above). |
| 7 | **Vague attribution** | "Many professionals find that..." instead of "I found that..." | Write in first person with specific personal detail — real numbers, named tools, real dates. |
| 8 | **Over-structured output** | Numbered lists, bullet points, and headers for everything | Default to prose. Use structure only when the idea genuinely calls for it. |
| 9 | **Explaining the obvious** | "LinkedIn is a professional networking platform" before making a point about LinkedIn | Assume the reader has context. Start at the insight. |
| 10 | **Closing with a summary** | Final paragraph restates the points made above | Never restate. Close by completing the circle back to the opening hook. |

---

## Australian English Conventions

All output uses Australian English.

> **Prefer US or UK English?** Swap the conventions in this section — and the bundled Vale `ProseAU` style (its spelling, date, and punctuation rules) plus the cspell language setting — to match. The linter enforces exactly what's configured, so this guide and the lint config must agree.

### Spelling (ABC Style Guide / SMH conventions)

| Convention | Use | Don't use |
|------------|-----|-----------|
| -ise endings | organise, realise, recognise | organize, realize, recognize |
| -our endings | behaviour, colour, labour | behavior, color, labor |
| -re endings | centre, metre | center, meter |
| -ence endings | licence (noun), defence | license (noun), defense |
| programme | programme (general), program (computing) | program (for non-computing) |
| -yse endings | analyse, paralyse | analyze, paralyze |
| Double-l | travelling, modelling | traveling, modeling |

### Punctuation

- **Double quotes** for direct speech and scare quotes. Single quotes are the traditional Australian convention; double quotes are equally acceptable in Australian usage, and this kit defaults to double. Pick one and hold it — the bundled quote-punctuation lint rule assumes double.
- **Full stop placement:** Outside closing quotes when the quote is part of a larger sentence. Inside when the quote is a standalone sentence.
- **Serial comma:** Not standard in Australian English. Omit unless required for clarity.
- **Dates:** 5 April 2026 (day-month-year, no ordinal suffixes, month spelled out). Acceptable short form: 5/4/2026 (not 4/5/2026).
- **Em dashes:** Use sparingly — like this — spaced, and limited to 2–3 per piece maximum. When tempted to use an em dash, prefer a full stop (for emphasis or fragments), a colon (for definitions or lists), a comma, or sentence restructuring. Em dashes are a spice, not a staple.
- **Numeric ranges:** En dash, unspaced — 2–3, pages 14–19, 2019–2024 — never a hyphen.

### Tone conventions from Australian editorial practice

- **Understated rather than emphatic.** ABC and SMH editorial culture favours dry precision over exclamation.
- **Directness without aggression.** State the position, acknowledge the counter-argument if warranted, move on. Don't hedge repeatedly.
- **Avoid Americanisms in idiom.** Avoid purely American idioms like "touch base", "circle back", "move the needle" — these also overlap with corporate jargon.

---

## Drafting Process — Questions Before Assumptions

When drafting or rewriting, flag any section where the argument would be stronger with specific detail, a real example, or a decision only the author can make. Don't fill the gap with generic prose — ask. Be specific about what's missing and why it matters: "Can you give me more detail here?" is not useful; "This section argues X — do you have a real case where you hit this? A specific example would make it land harder." is.

The goal: every gap in the draft becomes a question to the author, never a guess by the agent.

---

## Self-check before submitting a draft

1. **Sentence rhythm:** Do sentences vary in length? Is there at least one fragment and one longer complex sentence?
2. **Transitions:** Are any filler transitions present? Remove them. If the flow breaks without them, restructure.
3. **Vocabulary:** Scan for any word from the banned list above. Replace with a natural alternative.
4. **Opening:** Does it start mid-thought? If it opens with context-setting ("In today's rapidly evolving..."), cut the first paragraph — the real point usually starts in the second.
5. **Closing:** Does it link back to the opening hook? Is it the most interesting line in the piece? If it restates the argument, delete it.
6. **Specificity:** Does the draft include at least one concrete detail only the author could supply — a real number, a named tool, a date, an honest admission? If not, flag the gap for the author to fill rather than inventing one.
7. **Balance:** Does the piece take a clear position, or does it hedge everything? "This is an incentives problem" — not "While there are many factors at play, incentives are one important consideration."

---

## The One Rule

Apply this test to every sentence:

> Would you say this out loud to a smart colleague over coffee?

If yes, it stays. If it sounds like a press release, a LinkedIn influencer template, or generic AI output, rewrite it.
