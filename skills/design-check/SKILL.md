---
name: design-check
description: Measure a rendered page against its design and report the differences as numbers. Reads sizes, spacing, type, and colors from the live page in a browser and compares them with the design values. Use when the user asks "does it match the design", "check the pixels", "pixel QA", or when a flow task has a design. This measures a built page. It does not review whether a design is good.
---

# Design check

"It looks right" is not a result. Measure the page and compare the numbers.

A screenshot comparison can only tell you that something differs. A measurement
tells you what differs, where, and by how much, so the fix is one line.

Load the `evidence` skill first and report with its four result words.

## What you need

| Input | Notes |
|---|---|
| A page that runs | The address comes from `.flow/profile.md`, or ask. |
| The design values | A design tool you can read through a connector, a spec file, or values the user gives you. |
| A browser tool | Any tool that can run script in the page. Check that it exists. Never install one. |

If there is no design to compare with, the result is `could-not-run`. Do not
compare the page with your own idea of good design. If there is no browser
tool, the result is `could-not-run`.

## Steps

1. **Write the spec.** List the elements to check and the design value of each
   property. Mark each value `specified` if it comes from the design, or
   `derived` if you computed it from other values. Check only what the design
   defines.

2. **Match elements.** For each element, find one selector on the page. If you
   cannot find the element, that is a finding. Do not pick a similar one.

3. **Measure.** In the browser, at the viewport width of the design, read the
   computed style and the bounding box of each element:
   - size and position: width, height, gaps to neighbors
   - spacing: padding, margin, gap
   - type: family, size, weight, line height, letter spacing
   - color: text, background, border
   - shape: radius, border width

4. **Compare.** Use these limits unless the team set its own:
   - sizes and spacing: within 1px
   - font size, weight, family: exact
   - line height: within 1px
   - color: a difference a person cannot see. Compare with a perceptual color
     difference, not by matching hex strings.

5. **Repeat** for each viewport width the design defines.

## Rules

- Measure the real rendered page, not the source code. A class name is not a
  measurement.
- A check on a `derived` value that fails is a question, not a defect. Report
  it apart from the `specified` failures.
- Fonts must be loaded before you measure. A fallback font changes every size.
- A screenshot overlay may support a finding. It is never the finding.
- Do not edit the page. Report.

## Result

`passed`: every `specified` value is within the limits.
`failed`: at least one `specified` value is outside the limits.

## Report

```
## Design check: <page or section>
<n> passed, <n> failed, <n> not-run, <n> could-not-run
Viewports: <list>. Elements: <n>. Properties: <n>.

### Differences
| Element | Property | Design | Page | Difference | Source |
| Card title | font-size | 20px | 18px | -2px | specified |

### Questions
- <derived values that did not match>

### Not checked
- <elements or viewports left out, and why>
```
