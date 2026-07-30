[![Check PDF](https://github.com/achiefa/CV/actions/workflows/tests.yaml/badge.svg?branch=main)](https://github.com/achiefa/CV/actions/workflows/tests.yaml)
[![PDF deployed](https://github.com/achiefa/CV/actions/workflows/deploy.yaml/badge.svg?branch=main)](https://github.com/achiefa/CV/actions/workflows/deploy.yaml)

# CV

Two CV variants built from one shared set of content files.

| Variant | Driver | Published at |
|---|---|---|
| Academic / postdoc | `main-postdoc.tex` | [main.pdf](https://achiefa.github.io/CV/main.pdf) |
| Quant / data science | `main-quant.tex` | [main-quant.pdf](https://achiefa.github.io/CV/main-quant.pdf) |

## How it is organised

```
main-postdoc.tex     driver: picks the variant, the renderer, and the section ORDER
main-quant.tex       driver
style/
  cvbase.sty         shared layout, helpers, variant machinery. No content.
  render-postdoc.sty how entries look in the academic variant
  render-quant.sty   how entries look in the industry variant
content/             the facts, written once, used by both drivers
```

**Facts live in `content/` and are written exactly once.** A journal reference,
a date or a job title is edited in one place and both PDFs change.

**How a fact is displayed is decided by the renderer.** Each `style/render-*.sty`
defines `\pubentry`, `\expentry`, `\eduentry`, `\talkentry` and `\awardentry`.
The academic renderer prints full author lists and thesis titles; the industry
renderer prints one compact line and drops any publication not tagged `core`.

**Where the wording genuinely differs**, use the variant switches:

```latex
\cvtext{postdoc}{...}   % only in the academic CV
\cvtext{quant}{...}     % only in the industry CV
\cvnot{quant}{...}      % everywhere except the industry CV
```

**Section order** is controlled entirely by the driver — reordering a variant
means moving one line.

## Adding a third variant

1. Copy a driver, e.g. `main-industry.tex`, and `\setcvvariant{industry}`.
2. Copy a renderer to `style/render-industry.sty`.
3. Add `industry` to the `matrix.variant` list in both workflow files.

No content files need to change.

## Building locally

```bash
latexmk -pdf main-postdoc.tex
latexmk -pdf main-quant.tex
```

## Before sending a CV out

Placeholders are rendered in red as `[TODO: ...]`. Check none remain:

```bash
grep -rn "TODO" content/
```
