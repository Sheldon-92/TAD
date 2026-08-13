# Store Metadata — App Store Listing & ASO

App Store metadata: title, description, keywords, screenshots, localization.
TAD documentation output goes to `.tad/active/release/{project}/` (metadata-strategy.md, metadata-verification.md, metadata-optimization.md); the metadata files themselves go into the project (`fastlane/metadata/en-US/` or `app.json` for Expo).

## Step 1: Select Metadata Strategy

1. New app → create metadata from scratch
2. Existing app → `fastlane deliver download_metadata` to pull current metadata
3. Multi-language? → plan localization files per language
4. Define target keywords (search volume vs competition, 100-char limit)
5. Review competitors' App Store listings for keyword inspiration (web research)

Record decisions in `metadata-strategy.md`.

## Step 2: Create Metadata Files

Write to `fastlane/metadata/en-US/` (or `app.json` for Expo):

1. **Title** (≤30 chars): clear, includes primary keyword
2. **Subtitle** (≤30 chars): value proposition
3. **Keywords** (100 chars): comma-separated, no spaces after commas, no title duplicates
4. **Description**: feature-focused, not marketing fluff. First 3 lines visible without "more"
5. **Screenshots**: actual app, correct device sizes (6.7" + 6.1" minimum)
6. **App category**: select most accurate category

Expected file layout (native/fastlane):

```
fastlane/metadata/en-US/
├── name.txt
├── subtitle.txt
├── keywords.txt
├── description.txt
└── release_notes.txt
```

## Step 3: Verify Metadata Quality

Checklist (record in `metadata-verification.md`):

1. Title ≤ 30 chars? Subtitle ≤ 30 chars?
2. Keywords ≤ 100 chars? No title word duplicates?
3. Screenshots show actual app (not mockups)?
4. Description first 3 lines compelling?
5. All required device sizes present?

## Step 4: Optimize (ASO)

1. A/B test descriptions if possible (App Store Connect supports this)
2. Use all 100 keyword chars (don't waste space)
3. Avoid repeating words across title + subtitle + keywords
4. Localize for top markets (en, zh, ja, ko, de, fr minimum for global)

## Quality Criteria (pass/fail)

- Title ≤ 30 chars, subtitle ≤ 30 chars
- Keywords ≤ 100 chars, no title duplicates, no spaces after commas
- Screenshots show actual app (not mockups or renders)
- Description first 3 lines explain what the app does
- Fabricated download numbers or invented reviews = FAIL
