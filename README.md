[![Check PDF](https://github.com/achiefa/CV/actions/workflows/tests.yaml/badge.svg?branch=main)](https://github.com/achiefa/CV/actions/workflows/tests.yaml)
[![PDF deployed](https://github.com/achiefa/CV/actions/workflows/deploy.yaml/badge.svg?branch=main)](https://github.com/achiefa/CV/actions/workflows/deploy.yaml)

# CV

Several CV variants built from one shared content database.

| Variant | Driver | Published at |
|---|---|---|
| Academic / postdoc | `main-postdoc.tex` | [main.pdf](https://achiefa.github.io/CV/main.pdf) |
| Quant / data science | `main-quant.tex` | [main-quant.pdf](https://achiefa.github.io/CV/main-quant.pdf) |

## Design

```
main-postdoc.tex      driver: prose, WHICH entries appear, in WHAT order
main-quant.tex        driver
style/
  cvkit.sty           machinery only: the record store and \use... commands.
                      Knows nothing about content or about which variants exist.
  variant-postdoc.sty the academic LOOK + academic renderers
  variant-quant.sty   the industry LOOK + compact renderers
content/              the facts. Definitions only; these files print nothing.
```

The content files behave like a small `.bib`: they *define* entries and output
nothing. A driver *cites* the ones it wants.

```latex
% content/publications.tex
\definepub{ntk}
  {Quantitative Understanding of PDF Fits and their Uncertainties}
  {\me, L. Del Debbio, R. Kenway}
  {Published in: \textit{Eur.Phys.J.C 86 (2026) 6, 722}}{2512.24116}
```

```latex
% main-quant.tex -- selection and order live here, not in the content
\cvsection{Selected Publications}
\begin{cvlist}
  \item[] \footnotesize Six peer-reviewed publications since 2024. [...] \normalsize
  \usepub{ntk}
  \usepub{runii}
\end{cvlist}
```

Three consequences worth keeping:

- **Content never mentions a variant.** There are no `\if`-style switches in
  `content/`. Adding a fourth CV touches zero content files.
- **Selection is a driver decision.** Showing a different subset of papers is
  editing a list of `\usepub` lines, not adding tags or filter rules.
- **Look is a variant decision.** Each `style/variant-*.sty` owns its own
  geometry, fonts, headings and renderers, so two CVs can be genuinely
  different-looking documents rather than one template with tweaks.

### Registers

The one case where a fact needs different *wording* per audience is handled by
registers, which are tones of voice rather than variant names:

```latex
\definexp{nnpdf}{NNPDF Collaboration}{Developer}{since 11/2023}
\xpdesc{nnpdf}{academic}{Contribute to the maintenance and development of...}
\xpdesc{nnpdf}{industry}{Maintain and extend a production Python/C++ codebase...}
```

The driver asks for the tone it wants: `\usexp{nnpdf}{industry}`. Organisation,
role and dates still exist in exactly one place.

### Available commands

| Define (in `content/`) | Cite (in a driver) |
|---|---|
| `\definepub{key}{title}{authors}{venue}{arxiv}` | `\usepub{key}` |
| `\definexp{key}{org}{role}{dates}` + `\xpdesc{key}{register}{prose}` | `\usexp{key}{register}` |
| `\defineedu{key}{degree}{grade}{dates}{institution}{supervisor}{detail}` | `\useedu{key}` |
| `\definetalk{key}{title}{url}{date}{event}` | `\usetalk{key}` |
| `\defineaward{key}{name}{dates}{desc}` | `\useaward{key}` |
| `\defineskill{key}{label}{body}` | `\useskill{key}` |

Citing a key that does not exist is a hard build error, not a silent omission.

## Adding a variant

1. Copy a driver, e.g. `main-industry.tex`.
2. Copy a `style/variant-*.sty` and give it whatever look you want.
3. Add `industry` to `matrix.variant` in both workflow files.

No content files change.

## Building locally

```bash
latexmk -pdf main-postdoc.tex
latexmk -pdf main-quant.tex
```

## Checking a CV

```bash
cicd/spelling.sh main-quant.pdf    # spelling + leftover [TODO: ...] placeholders
cicd/Length.sh   main-quant.pdf    # fails above two pages
```

Both run in CI on every push and pull request, for both variants.

The spell checker reads the *rendered text* of the PDF rather than the LaTeX
source. That is deliberate: entry keys, command names, lengths and arXiv IDs are
not words, and checking the source meant every one of them had to be whitelisted
in `dict/words` before CI would go green. Checking the PDF means `dict/words`
holds domain vocabulary only, and adding a `\definepub{key}` never touches it.

Placeholders render in red as `[TODO: ...]` and are a hard failure, so a CV with
an unresolved placeholder cannot pass.
