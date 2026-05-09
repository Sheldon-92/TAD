---
name: TAD Phase 4 Test Design System (Valid)
colors:
  primary: "#1A6FD3"
  background: "#FFFFFF"
typography:
  h1:
    fontFamily: "Inter Tight"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: "1.2"
    letterSpacing: "-0.02em"
  body:
    fontFamily: "Inter"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: "1.5"
    letterSpacing: "0em"
spacing:
  base: "8px"
  lg: "16px"
rounded:
  md: "8px"
components:
  button:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.background}"
    padding: "{spacing.base} {spacing.lg}"
    rounded: "{rounded.md}"
---

## Overview

A minimal valid DESIGN.md fixture to exercise lint PASS on Phase 4.

## Colors

`{colors.primary}` is the dominant accent on `{colors.background}`.

## Typography

Inter Tight for headings, Inter for body.

## Layout

8px base grid.

## Elevation & Depth

Use rounded corners for raised elements.

## Shapes

Consistent rounded corners across components.

## Components

See `components.button`.

## Do's and Don'ts

- Do: use semantic token references.
- Don't: hard-code hex values.
