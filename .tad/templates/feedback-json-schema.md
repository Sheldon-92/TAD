# Feedback JSON Schema v1.0

> Canonical reference for the JSON exported by Blake's feedback HTML files.
> Blake's HTML "Export JSON" button MUST produce output conforming to this schema.
> Phase 2 Alex reader will parse this format as-is. Future versions are additive-only.

## Schema

```json
{
  "version": "1.0",
  "artifact_type": "frontend_page|audio|video|design|brand|generic",
  "artifact_path": "relative/path/to/artifact",
  "feedback_html_path": "relative/path/to/feedback.html",
  "timestamp": "ISO 8601 timestamp",
  "elements_total": 12,
  "elements": [
    {
      "id": "hero-title",
      "label": "Page title",
      "element_type": "heading",
      "selector_type": "css",
      "selector_value": "h1.hero-title",
      "reviewed": true,
      "verdict": "modify",
      "structured_feedback": {
        "text": "Updated Title Here",
        "style": "make it larger",
        "position": null
      },
      "free_text": "This title doesn't match our brand voice",
      "priority": "high"
    }
  ],
  "global_notes": "Overall feedback about the artifact as a whole",
  "meta": {
    "iteration": 1,
    "prev_feedback": null
  }
}
```

## Field Reference

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | string | yes | Schema version. Always `"1.0"` for Phase 1. |
| `artifact_type` | enum | yes | One of: `frontend_page`, `audio`, `video`, `design`, `brand`, `generic` |
| `artifact_path` | string | yes | Relative path from project root to the artifact file |
| `feedback_html_path` | string | yes | Relative path to the feedback HTML that generated this JSON |
| `timestamp` | string | yes | ISO 8601 timestamp of export |
| `elements_total` | integer | yes | Total number of reviewable cards in the HTML |
| `elements` | array | yes | One entry per reviewable element (see below) |
| `global_notes` | string | no | Free-text notes about the artifact as a whole |
| `meta` | object | yes | Iteration tracking metadata |

### Element Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Semantically meaningful, stable across regenerations (e.g., `hero-title`, `segment-0015-0030`) |
| `label` | string | yes | Human-readable name for the element |
| `element_type` | string | yes | What the element IS: `heading`, `button`, `image`, `audio_segment`, `color_swatch`, `section`, etc. |
| `selector_type` | enum | yes | Addressing scheme: `css` (DOM), `time_range` (audio/video), `spatial` (image coords), `semantic` (description-based) |
| `selector_value` | string | yes | Selector value matching the type (e.g., `h1.hero-title` for css, `00:15-00:30` for time_range) |
| `reviewed` | boolean | yes | `true` only if user interacted with this card. Distinguishes "reviewed and OK" from "skipped entirely" |
| `verdict` | enum | yes if reviewed | `ok`, `modify`, `delete`, `replace`. Null if not reviewed. |
| `structured_feedback` | object | no | Typed modification instructions (see below) |
| `free_text` | string | no | Free-form feedback for this element |
| `priority` | enum | no | `high`, `medium`, `low`. Null if not set. |

### Structured Feedback Fields

| Field | Type | Description |
|-------|------|-------------|
| `text` | string | New text content or text modification instruction |
| `style` | string | Visual/style modification instruction |
| `position` | string | Layout/position modification instruction |

### Meta Fields

| Field | Type | Description |
|-------|------|-------------|
| `iteration` | integer | Feedback round number (1 for first round, incremented by Alex on subsequent rounds). Read from the `data-iteration` attribute on the HTML page root element, set by Blake at generation time. |
| `prev_feedback` | string | Path to previous feedback JSON (null for first iteration) |

## Selector Type Examples

| `selector_type` | `selector_value` example | Use case |
|-----------------|--------------------------|----------|
| `css` | `h1.hero-title` | DOM elements in frontend pages |
| `time_range` | `00:15-00:30` | Audio/video segments |
| `spatial` | `x:120,y:80,w:200,h:150` | Image regions, design components |
| `semantic` | `the tagline below the logo` | When no programmatic selector exists |

## Examples

### Minimal (single element, no feedback yet)

```json
{
  "version": "1.0",
  "artifact_type": "frontend_page",
  "artifact_path": "output/landing-page.html",
  "feedback_html_path": "output/landing-page-feedback.html",
  "timestamp": "2026-06-10T14:30:00Z",
  "elements_total": 1,
  "elements": [
    {
      "id": "hero-title",
      "label": "Hero section title",
      "element_type": "heading",
      "selector_type": "css",
      "selector_value": "h1.hero-title",
      "reviewed": false,
      "verdict": null,
      "structured_feedback": null,
      "free_text": null,
      "priority": null
    }
  ],
  "global_notes": "",
  "meta": {
    "iteration": 1,
    "prev_feedback": null
  }
}
```

### Full (audio artifact, multiple elements with feedback)

```json
{
  "version": "1.0",
  "artifact_type": "audio",
  "artifact_path": "podcasts/EP05/final/EP05-final.wav",
  "feedback_html_path": "podcasts/EP05/final/EP05-final-feedback.html",
  "timestamp": "2026-06-10T16:45:00Z",
  "elements_total": 4,
  "elements": [
    {
      "id": "segment-0000-0030",
      "label": "Opening (0:00-0:30)",
      "element_type": "audio_segment",
      "selector_type": "time_range",
      "selector_value": "00:00-00:30",
      "reviewed": true,
      "verdict": "ok",
      "structured_feedback": null,
      "free_text": null,
      "priority": null
    },
    {
      "id": "segment-0030-0115",
      "label": "Introduction (0:30-1:15)",
      "element_type": "audio_segment",
      "selector_type": "time_range",
      "selector_value": "00:30-01:15",
      "reviewed": true,
      "verdict": "modify",
      "structured_feedback": {
        "text": null,
        "style": "pacing too fast, slow down by 10%",
        "position": null
      },
      "free_text": "The transition into the main topic feels rushed",
      "priority": "high"
    },
    {
      "id": "segment-0115-0300",
      "label": "Main content (1:15-3:00)",
      "element_type": "audio_segment",
      "selector_type": "time_range",
      "selector_value": "01:15-03:00",
      "reviewed": false,
      "verdict": null,
      "structured_feedback": null,
      "free_text": null,
      "priority": null
    },
    {
      "id": "bgm-track",
      "label": "Background music",
      "element_type": "audio_track",
      "selector_type": "semantic",
      "selector_value": "background music throughout episode",
      "reviewed": true,
      "verdict": "replace",
      "structured_feedback": {
        "text": null,
        "style": "too upbeat for the topic, try something more contemplative",
        "position": null
      },
      "free_text": "The BGM competes with the voice in the 0:30-1:15 segment",
      "priority": "medium"
    }
  ],
  "global_notes": "Overall good quality. The opening is strong but the pacing dips in the middle.",
  "meta": {
    "iteration": 1,
    "prev_feedback": null
  }
}
```

## Versioning Rules

- Phase 2 parser MUST accept v1.0 JSONs as-is
- New fields in future versions MUST be optional (additive-only)
- Breaking changes require major version bump AND feedback HTML regeneration
- The `version` field enables the parser to handle different schema versions gracefully
