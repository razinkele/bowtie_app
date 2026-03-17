# Scientific Causal Knowledge Base for Bowtie Risk Analysis

**Date**: 2026-03-17
**Status**: Approved
**Version**: 1.0

## Problem

The current AI linker (`vocabulary_ai_linker.R`) uses keyword heuristics and Jaccard similarity to create connections between vocabulary items. This produces scientifically indefensible connections (e.g., linking marine tourism to agricultural runoff because both mention "water"). The vocabulary is structured according to MSFD/DPSIR frameworks and has well-established causal relationships in published literature.

## Solution

Replace keyword heuristics with a curated expert knowledge matrix (`causal_knowledge_base.R`) encoding ~550 validated causal connections from peer-reviewed marine science literature.

## Data Structure

```r
CAUSAL_KB <- list(
  activity_pressure = data.frame(
    from_id, to_id, confidence, confidence_score,
    msfd_descriptor, mechanism, citation
  ),
  pressure_consequence = data.frame(
    from_id, to_id, confidence, confidence_score,
    msfd_descriptor, mechanism, citation
  ),
  control_pressure = data.frame(
    from_id, to_id, confidence, confidence_score,
    effectiveness, mechanism, citation
  ),
  references = data.frame(
    key, authors, year, title, journal, doi, url
  )
)
```

## Confidence Mapping

| Evidence Level | Score | Label |
|---|---|---|
| Multiple studies + regulatory framework | 0.95 | very_high |
| Published impact chain matrix | 0.85 | high |
| Single study or expert assessment | 0.70 | medium |
| Plausible but limited evidence | 0.50 | low |

## Integration

1. New method `"knowledge_base"` in `find_vocabulary_links()`
2. Checked first, before keyword/jaccard
3. Existing methods kept as fallback for custom items
4. References accessible via `get_kb_references()` for UI/export

## Files

- NEW: `causal_knowledge_base.R`
- EDIT: `vocabulary_ai_linker.R` (add knowledge_base method)
- EDIT: `global.R` (source new file)
- EDIT: `constants.R` (add threshold constant)

## Key References

- Knights et al. 2015 — ODEMM linkage framework
- Borgwardt et al. 2019 — Cross-aquatic ecosystem assessment
- Korpinen et al. 2021 — Combined effects on European marine ecosystems
- HELCOM HOLAS 3 — Baltic Sea pressure index
- MSFD Commission Decision 2017/848 — GES criteria
- OSPAR QSR 2023 — Quality Status Report
- Halpern et al. 2015 — Global cumulative impact assessment
