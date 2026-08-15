-- graph.sqlite — per-topic knowledge graph for a research corpus
--
-- Source files (markdown, pdf txts) stay on disk. This DB stores extracted
-- concepts, claims, and cross-ref relations. One DB file per corpus.

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

-- ─── Source documents ────────────────────────────────────────────────────────

CREATE TABLE refs (
    ref_id          TEXT PRIMARY KEY,           -- slug e.g. 'mollick-2025-cybernetic-teammate'
    source_path     TEXT NOT NULL UNIQUE,       -- relative to corpus root
    authors         TEXT,                       -- JSON array
    year            INTEGER,
    title           TEXT,
    venue           TEXT,
    url             TEXT,                       -- canonical public URL (DOI / arXiv / publisher / archive); required for inline/hybrid citation rendering
    tier            INTEGER,                    -- 1–5 reading tier, NULL if unassigned
    notes           TEXT                        -- freeform operator notes
);

-- One row per extraction run. Lets us re-run with a newer model and keep history.
CREATE TABLE extractions (
    extraction_id   INTEGER PRIMARY KEY,
    ref_id          TEXT NOT NULL REFERENCES refs(ref_id) ON DELETE CASCADE,
    source_sha256   TEXT NOT NULL,              -- hash of source file at extraction time
    extractor_model TEXT NOT NULL,              -- e.g. 'claude-opus-4-6'
    extracted_at    TEXT NOT NULL DEFAULT (datetime('now')),
    is_current      INTEGER NOT NULL DEFAULT 1, -- 0 for superseded runs
    prompt_version  TEXT,                       -- tag for the extraction prompt used
    UNIQUE (ref_id, source_sha256, extractor_model)
);
CREATE INDEX idx_extractions_current ON extractions(ref_id) WHERE is_current = 1;

-- ─── Concept glossary (deduplicated across corpus) ───────────────────────────

CREATE TABLE concepts (
    concept_id      TEXT PRIMARY KEY,           -- slug e.g. 'jagged-frontier'
    label           TEXT NOT NULL,
    kind            TEXT NOT NULL CHECK (kind IN ('concept','mechanism','finding','framework')),
    definition      TEXT,
    first_seen_ref  TEXT REFERENCES refs(ref_id) ON DELETE SET NULL
);

-- Which refs use/define which concepts, and with what evidence.
CREATE TABLE ref_concepts (
    ref_id          TEXT NOT NULL REFERENCES refs(ref_id) ON DELETE CASCADE,
    concept_id      TEXT NOT NULL REFERENCES concepts(concept_id) ON DELETE CASCADE,
    role            TEXT NOT NULL CHECK (role IN ('defines','uses','extends','critiques')),
    evidence_quote  TEXT,
    evidence_locator TEXT,                      -- e.g. 'p.12', 'abstract', '§3.2'
    confidence      TEXT NOT NULL CHECK (confidence IN ('EXTRACTED','INFERRED','AMBIGUOUS')),
    score           REAL,                       -- 0–1 for INFERRED, else NULL
    extraction_id   INTEGER NOT NULL REFERENCES extractions(extraction_id) ON DELETE CASCADE,
    PRIMARY KEY (ref_id, concept_id, role, extraction_id)
);

-- ─── Claims (atomic propositions extracted from each ref) ────────────────────

CREATE TABLE claims (
    claim_id        INTEGER PRIMARY KEY,
    ref_id          TEXT NOT NULL REFERENCES refs(ref_id) ON DELETE CASCADE,
    extraction_id   INTEGER NOT NULL REFERENCES extractions(extraction_id) ON DELETE CASCADE,
    statement       TEXT NOT NULL,
    evidence_locator TEXT,
    confidence      TEXT NOT NULL CHECK (confidence IN ('EXTRACTED','INFERRED','AMBIGUOUS'))
);
CREATE INDEX idx_claims_ref ON claims(ref_id);

CREATE TABLE claim_concepts (
    claim_id        INTEGER NOT NULL REFERENCES claims(claim_id) ON DELETE CASCADE,
    concept_id      TEXT NOT NULL REFERENCES concepts(concept_id) ON DELETE CASCADE,
    PRIMARY KEY (claim_id, concept_id)
);

-- ─── Cross-ref relations (the graph edges between documents) ─────────────────

CREATE TABLE relations (
    relation_id     INTEGER PRIMARY KEY,
    source_ref      TEXT NOT NULL REFERENCES refs(ref_id) ON DELETE CASCADE,
    target_ref      TEXT NOT NULL REFERENCES refs(ref_id) ON DELETE CASCADE,
    type            TEXT NOT NULL CHECK (type IN (
                        'cites','extends','contradicts',
                        'shares_concept_with','evidence_for','background_for'
                    )),
    note            TEXT,
    confidence      TEXT NOT NULL CHECK (confidence IN ('EXTRACTED','INFERRED','AMBIGUOUS')),
    score           REAL,
    extraction_id   INTEGER NOT NULL REFERENCES extractions(extraction_id) ON DELETE CASCADE,
    UNIQUE (source_ref, target_ref, type, extraction_id)
);
CREATE INDEX idx_relations_source ON relations(source_ref);
CREATE INDEX idx_relations_target ON relations(target_ref);

-- ─── Full-text search over claims ────────────────────────────────────────────

CREATE VIRTUAL TABLE claims_fts USING fts5(
    statement,
    content='claims',
    content_rowid='claim_id'
);

CREATE TRIGGER claims_ai AFTER INSERT ON claims BEGIN
    INSERT INTO claims_fts(rowid, statement) VALUES (new.claim_id, new.statement);
END;
CREATE TRIGGER claims_ad AFTER DELETE ON claims BEGIN
    INSERT INTO claims_fts(claims_fts, rowid, statement) VALUES('delete', old.claim_id, old.statement);
END;
CREATE TRIGGER claims_au AFTER UPDATE ON claims BEGIN
    INSERT INTO claims_fts(claims_fts, rowid, statement) VALUES('delete', old.claim_id, old.statement);
    INSERT INTO claims_fts(rowid, statement) VALUES (new.claim_id, new.statement);
END;

-- ─── Convenience views (current extractions only) ────────────────────────────

CREATE VIEW v_current_claims AS
    SELECT c.* FROM claims c
    JOIN extractions e ON e.extraction_id = c.extraction_id
    WHERE e.is_current = 1;

CREATE VIEW v_current_relations AS
    SELECT r.* FROM relations r
    JOIN extractions e ON e.extraction_id = r.extraction_id
    WHERE e.is_current = 1;

CREATE VIEW v_current_ref_concepts AS
    SELECT rc.* FROM ref_concepts rc
    JOIN extractions e ON e.extraction_id = rc.extraction_id
    WHERE e.is_current = 1;
