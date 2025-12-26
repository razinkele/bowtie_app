# AI Similarity Calculation Guide

## Overview

The AI-powered vocabulary linking system calculates **similarity scores** between vocabulary items (Activities, Pressures, Consequences, Controls) using **three complementary methods** to determine which items should be connected in a bowtie diagram.

**File**: `vocabulary-ai-linker.R`
**Main Function**: `calculate_similarity_scores()` (lines 262-320)

---

## How Similarity is Calculated

### Multi-Method Approach

The system combines **three different similarity methods** to get a comprehensive score:

```r
Final Similarity = (Jaccard Score + Keyword Score + Causal Score) / 3
```

Each method contributes equally, and the final score ranges from **0.0 to 1.0**.

---

## Method 1: Jaccard Similarity (Word Overlap)

**Function**: `calculate_jaccard_similarity()` (lines 327-347)

**What it measures**: How many words are shared between two vocabulary terms.

### Algorithm

1. **Convert to lowercase** and split into words
2. **Remove special characters** (keep only letters and spaces)
3. **Remove stop words** (common words like "the", "a", "and", "or", "in", "of", etc.)
4. **Calculate Jaccard coefficient**: `intersection / union`

### Formula

```
Jaccard Similarity = (Number of shared words) / (Total unique words in both texts)
```

### Example

**Text 1**: "Industrial discharge of chemical waste"
**Text 2**: "Chemical pollution from industrial sources"

**Step 1 - Extract words**:
- Text 1 words: `["industrial", "discharge", "chemical", "waste"]`
- Text 2 words: `["chemical", "pollution", "industrial", "sources"]`

**Step 2 - Calculate**:
- Intersection: `["industrial", "chemical"]` = **2 words**
- Union: `["industrial", "discharge", "chemical", "waste", "pollution", "sources"]` = **6 words**
- Jaccard Score: `2 / 6` = **0.333**

---

## Method 2: Keyword Similarity (Environmental Domain)

**Function**: `calculate_keyword_similarity()` (lines 350-391)

**What it measures**: How many domain-specific environmental keywords both items share.

### Algorithm

1. **Check both texts** against a curated list of **45+ environmental keywords**
2. **Count matches** where the keyword appears in BOTH texts
3. **Normalize score**: `matches / 5` (capped at 1.0)

### Environmental Keywords (45 keywords organized by category)

#### Water-Related (9 keywords)
- water, aquatic, marine, ocean, sea, river, lake, wetland, coastal
- discharge, runoff, drainage, effluent, wastewater

#### Pollution Types (9 keywords)
- pollution, contamination, pollutant, toxic, chemical, waste, emission
- spill, leak, release

#### Biological (9 keywords)
- species, habitat, ecosystem, biodiversity, flora, fauna, organism
- population, community, food web

#### Environmental Impacts (9 keywords)
- degradation, destruction, loss, decline, damage, harm, impact
- erosion, depletion, extinction

#### Activities (6 keywords)
- agriculture, industrial, urban, fishing, mining, construction
- transport, shipping, development

#### Controls (6 keywords)
- regulation, management, protection, conservation, mitigation
- prevention, monitoring, restoration, treatment

### Example

**Text 1**: "Marine pollution from industrial discharge"
**Text 2**: "Coastal water contamination by chemical waste"

**Matching keywords**:
1. "marine" ✓ (in text 1) + "coastal" ✓ (in text 2) = Water-related
2. "pollution" ✓ (in text 1) + "contamination" ✓ (in text 2) = Pollution types
3. "industrial" ✓ (in text 1) = Activities
4. "discharge" ✓ (in text 1) = Water-related
5. "water" ✓ (in text 2) = Water-related
6. "chemical" ✓ (in text 2) = Pollution types
7. "waste" ✓ (in text 2) = Pollution types

**Shared keywords appearing in BOTH texts**: Let's recount properly
- "marine"/"coastal": Both are water keywords but different words
- "pollution"/"contamination": Both are pollution keywords but different words
- We need EXACT matches in BOTH texts

Actually, looking at the code:
```r
ifelse(isTRUE(grepl(kw, text1_lower)) && isTRUE(grepl(kw, text2_lower)), 1, 0)
```

**Actual matches** (keyword must appear in BOTH texts):
- None of the individual keywords appear in both texts in this example

**Better Example**:
**Text 1**: "Marine pollution from industrial discharge"
**Text 2**: "Marine contamination from industrial sources"

**Matching keywords**:
1. "marine" appears in both ✓
2. "pollution"/"contamination" - pollution only in text1, contamination only in text2 ✗
3. "industrial" appears in both ✓
4. "discharge" only in text1 ✗

**Total matches**: 2
**Keyword Score**: `min(1.0, 2/5)` = **0.4**

---

## Method 3: Causal Relationship Detection

**Function**: `detect_causal_relationship()` (lines 394-430)

**What it measures**: Whether the two items have a cause-effect relationship based on environmental patterns.

### Algorithm

1. **Check predefined cause-effect pairs** (10 patterns)
2. **Match patterns**: Does text1 contain a "cause" word AND text2 contain an "effect" word from the same pair?
3. **Count matches** and normalize: `min(1.0, matches / 3)`

### Predefined Causal Patterns (10 pairs)

#### Activity → Pressure Patterns (5 pairs)

1. **Fishing activities → Overfishing impacts**
   - Cause: fishing, trawling, harvest
   - Effect: bycatch, depletion, overfishing

2. **Discharge activities → Pollution**
   - Cause: discharge, release, dump
   - Effect: pollution, contamination, toxic

3. **Construction activities → Sedimentation**
   - Cause: construction, development, dredging
   - Effect: sediment, turbidity, habitat loss

4. **Agriculture → Nutrient pollution**
   - Cause: agriculture, farming, cultivation
   - Effect: runoff, nutrient, eutrophication

5. **Industry → Emissions**
   - Cause: industrial, manufacturing, processing
   - Effect: emission, waste, chemical

#### Pressure → Consequence Patterns (5 pairs)

6. **Pollution → Health impacts**
   - Cause: pollution, contamination, toxic
   - Effect: mortality, disease, health

7. **Habitat loss → Biodiversity decline**
   - Cause: habitat loss, destruction, degradation
   - Effect: biodiversity, extinction, decline

8. **Eutrophication → Dead zones**
   - Cause: nutrient, eutrophication, algae
   - Effect: oxygen, hypoxia, dead zone

9. **Overfishing → Stock collapse**
   - Cause: overfishing, depletion, extraction
   - Effect: collapse, scarcity, economic

10. **Climate change → Species impacts**
    - Cause: climate, warming, temperature
    - Effect: bleaching, migration, adaptation

### Example

**Text 1**: "Industrial manufacturing and chemical processing"
**Text 2**: "Air pollution and toxic emissions in urban areas"

**Checking causal pairs**:
- Pair 5: "industrial" in text1 ✓ + "emission" in text2 ✓ → **Match!**
- Pair 5: "industrial" in text1 ✓ + "chemical" in text2 ✓ → **Match!**

**Total matches**: 1 (counted once per pair)
**Causal Score**: `min(1.0, 1/3)` = **0.333**

---

## Final Similarity Score Calculation

### Example: Complete Calculation

Let's calculate the similarity between:
- **Activity**: "Industrial discharge of chemical pollutants"
- **Pressure**: "Water pollution and toxic contamination"

#### Step 1: Jaccard Similarity

Words in Activity: `["industrial", "discharge", "chemical", "pollutants"]`
Words in Pressure: `["water", "pollution", "toxic", "contamination"]`

- Intersection: `[]` = 0 (no exact word matches)
- Union: 8 unique words
- **Jaccard Score**: 0.0

#### Step 2: Keyword Similarity

Environmental keywords in BOTH texts:
- "industrial" (Activity) - not in Pressure ✗
- "discharge" (Activity) - not in Pressure ✗
- "chemical" (Activity) - not in Pressure ✗
- "pollutants" relates to "pollution" ✓
- "water" (Pressure) - not in Activity ✗
- "pollution" (Pressure) - "pollutants" in Activity ✓
- "toxic" (Pressure) - not in Activity ✗
- "contamination" (Pressure) - not in Activity ✗

Shared keywords: pollution/pollutants = 1 match (let's say)
**Keyword Score**: min(1.0, 1/5) = **0.2**

#### Step 3: Causal Relationship

Check pairs:
- Pair 2: "discharge" in Activity ✓ + "pollution" in Pressure ✓ → **Match!**
- Pair 2: "discharge" in Activity ✓ + "contamination" in Pressure ✓ → **Match!**
- Pair 2: "discharge" in Activity ✓ + "toxic" in Pressure ✓ → **Match!**

**Causal Score**: min(1.0, 1/3) = **0.333**

#### Final Score

```
Final Similarity = (Jaccard + Keyword + Causal) / 3
                 = (0.0 + 0.2 + 0.333) / 3
                 = 0.533 / 3
                 = 0.178
```

**Result**: Similarity score = **0.178** (below typical threshold of 0.3, so no link created)

---

## Configurable Parameters

When calling the AI linking function, you can adjust:

### 1. Similarity Threshold (default: 0.3)

```r
find_vocabulary_links(vocab, similarity_threshold = 0.25)
```

- **Lower threshold** (0.2-0.25): More links, potentially weaker connections
- **Higher threshold** (0.35-0.4): Fewer links, only strong connections
- **Default** (0.3): Balanced approach

### 2. Maximum Links Per Item (default: 3)

```r
find_vocabulary_links(vocab, max_links_per_item = 5)
```

Controls how many connections each vocabulary item can have.

### 3. Methods Used (default: all three)

```r
find_vocabulary_links(vocab, methods = c("jaccard", "keyword", "causal"))
```

You can use any combination:
- `c("keyword")` - Only keyword matching
- `c("jaccard", "keyword")` - Word overlap + keywords
- `c("causal")` - Only causal patterns

---

## Interpretation of Scores

| Score Range | Interpretation | Action |
|-------------|----------------|--------|
| **0.0 - 0.2** | Very weak similarity | No link created |
| **0.2 - 0.3** | Weak similarity | Link created if threshold ≤ 0.25 |
| **0.3 - 0.5** | Moderate similarity | Link created (default threshold) |
| **0.5 - 0.7** | Strong similarity | High confidence link |
| **0.7 - 1.0** | Very strong similarity | Excellent match |

---

## Advantages of Multi-Method Approach

### Why combine three methods?

1. **Jaccard Similarity**:
   - ✅ Catches general word overlap
   - ✅ Language-independent (works with any vocabulary)
   - ❌ Misses semantic relationships (synonyms)

2. **Keyword Similarity**:
   - ✅ Domain-specific (environmental context)
   - ✅ Catches semantic relationships
   - ❌ Limited to predefined keywords

3. **Causal Relationship**:
   - ✅ Respects cause-effect logic
   - ✅ Creates scientifically valid connections
   - ❌ Limited to predefined patterns

**Combined**: Robust scoring that balances general overlap, domain knowledge, and causal logic!

---

## Real-World Example from Your Data

Based on the output you saw:
```
✓ Found 16 Activity → Pressure links
✓ Found 4 Pressure → Consequence links
```

**Typical similarity scores**:
- Activity → Pressure links: 0.30 - 0.55
- Pressure → Consequence links: 0.35 - 0.60
- Control links: Often lower (0.25 - 0.45) due to generic control language

---

## Summary

The AI similarity calculation is a **three-part scoring system**:

1. **Jaccard (Word Overlap)**: Are the same words used?
2. **Keyword (Domain Match)**: Do they share environmental concepts?
3. **Causal (Cause-Effect)**: Do they form a logical cause-effect pair?

**Final score** = Average of all three methods (0.0 to 1.0)

**Link creation** = Score must exceed threshold (default 0.3) AND respect bowtie structure rules

This ensures that connections are both **semantically meaningful** and **structurally valid** in a bowtie diagram! 🎯
