---
title: Quarto and Julia
---

!!! tip

    The concepts behind `format: typst` (render pipeline, parameters, figures, tables, YAML knobs) live on the [Quarto overview page](index.md). This page only covers the Julia-specific pieces.

Quarto supports Julia through two different engines. The recommended path is the **native Julia engine**, backed by [`QuartoNotebookRunner.jl`](https://github.com/PumasAI/QuartoNotebookRunner.jl). It runs your cells directly in a long-lived Julia worker process, so you avoid the Jupyter round trip and keep a warm session between renders.

!!! note

    The native Julia engine is available from **Quarto 1.7 and later**. For older Quarto versions (or setups that already rely on Jupyter), use `IJulia` instead. Both paths are shown below.

## Prerequisites

You need three things installed locally:

- [Quarto CLI](https://quarto.org/docs/get-started/), version 1.7 or later for the native engine.
- Julia itself (1.10 or newer recommended).
- Either nothing extra (native engine) or `IJulia` (Jupyter fallback).

=== "Native engine (recommended)"

    No manual package installation is required. The first time you render a document with `engine: julia`, Quarto installs `QuartoNotebookRunner.jl` into a private environment that it manages for you.

=== "IJulia (fallback)"

    Install `IJulia` into your default Julia environment:

    ```julia
    using Pkg
    Pkg.add("IJulia")
    ```

    When using this engine, Quarto treats the document like a Python notebook and starts an `IJulia` kernel through `jupyter`.

For the rest of the tutorial we also need `CairoMakie`, `DataFrames`, and `SummaryTables`:

```julia
using Pkg
Pkg.add(["CairoMakie", "DataFrames", "SummaryTables"])
```

## A minimal Typst document

Create a file called `report.qmd` with the following contents:

````md title="report.qmd"
---
title: My first Typst report
engine: julia
format: typst
---

This report was written in Quarto and compiled with Typst.

```{julia}
xs = [1, 2, 3, 4, 5]
sum(xs) / length(xs)
```
````

The `engine: julia` line opts in to the native Julia engine. Without it, Quarto falls back to the jupyter engine for backwards compatibility, which requires `IJulia`.

Render it:

```bash
quarto render report.qmd
```

The first render downloads and precompiles `QuartoNotebookRunner.jl` into Quarto's private environment, which can take a minute or two. Subsequent renders are much faster because the worker is kept warm.

## Building a small report

We now grow that skeleton into a real, parameterised sales report. Each step below is a small addition to the previous `report.qmd`.

### Step 1: add parameters and a setup cell

Under the native Julia engine, a `params:` block in the YAML exposes each entry as a **top-level constant** named after its key. Keys must be valid Julia identifiers (`snake_case` is fine, hyphens are not).

````md title="report.qmd"
---
title: Regional sales report
engine: julia
format: typst
params:
  region: North
  year: 2026
---

```{julia}
#| include: false

using CairoMakie
using DataFrames
using SummaryTables
```
````

The `#| include: false` option hides the setup cell from the output but still runs it. Inside any cell below, `region` and `year` are already defined, no `params[...]` lookup is needed.

### Step 2: computed values inline in prose

Add a short introduction that quotes the parameters directly in the text:

````md
## Overview

This report covers the **`{julia} region`** region for the year
**`{julia} year`**. Values below are quarterly totals in thousands.
````

The `` `{julia} ... ` `` inline backticks evaluate a Julia expression and splice its result into the paragraph.

### Step 3: a figure with `CairoMakie`

`CairoMakie` is the vector-friendly backend of `Makie`. It draws directly to a Cairo surface, which gives you crisp SVG or PDF output suitable for a Typst document.

````md
## Sales by quarter

```{julia}
#| label: fig-sales
#| fig-cap: Quarterly sales for the selected region.
#| fig-alt: Bar chart of quarterly sales, one bar per quarter.
#| fig-format: svg
#| fig-width: 6
#| fig-height: 3.5

sales = DataFrame(
    quarter = ["Q1", "Q2", "Q3", "Q4"],
    total = [120, 135, 158, 172],
)

fig = Figure(size = (600, 350))
ax = Axis(
    fig[1, 1],
    xlabel = "",
    ylabel = "Sales (k)",
    xticks = (1:4, sales.quarter),
)
barplot!(ax, 1:4, sales.total, color = "#2a9d8f")
fig
```

@fig-sales shows steady growth across the year.
````

Three things to notice:

- `fig-format: svg` keeps the plot as a vector image inside the PDF. This is almost always what you want for `format: typst`.
- Returning `fig` as the cell's last expression is what makes Quarto pick it up as a figure. An explicit `display(fig)` call is not needed.
- The cross-reference `@fig-sales` is resolved by Quarto as a Typst reference, so the text "Figure 1" and the page number are correct.
  The `fig-` prefix on the label is what triggers cross-referencing; `tbl-` does the same for tables.

### Step 4: a table with `SummaryTables`

[`SummaryTables.jl`](https://pumasai.github.io/SummaryTables.jl/stable/) is a publication-focused table package that supports HTML, DOCX, LaTeX, and **Typst** output. When used in a Quarto document with `format: typst`, it emits Typst table code directly, which means you keep searchable text and proper page breaks rather than getting a flat image.

````md
## Sales table

```{julia}
#| label: tbl-sales
#| tbl-cap: Quarterly totals for the selected region.

listingtable(
    sales,
    :total;
    rowgroup = :quarter,
    summary = :total => sum => "Total",
)
```

@tbl-sales lists the same numbers shown in @fig-sales.
````

!!! note

    `SummaryTables.jl` offers several high-level helpers (`listingtable`, `summarytable`, `table_one`) aimed at different reporting patterns. See its [documentation](https://pumasai.github.io/SummaryTables.jl/stable/) for the full API. For a simpler but less featureful option, returning a `DataFrame` directly also renders as a table, via Pandoc's automatic Markdown-to-Typst conversion.

### Step 5: render with a different parameter

The whole point of `params:` is that a second render with different values produces a different PDF from the same source:

```bash
quarto render report.qmd -P region:South -P year:2025
```

The inline prose and captions update to match. Under the native engine, the warm worker keeps compilation overhead low between renders.

## Gotcha: time to first plot

The first `CairoMakie` (or other plotting) call in a fresh Julia session triggers a compilation cascade known as **TTFX** (time to first X). Depending on the machine, this can take 10 to 30 seconds on top of Quarto's own startup. If your render feels stuck on the first plot cell, it probably is not stuck, it is compiling.

Two things help:

- Keep the same `QuartoNotebookRunner.jl` worker warm between renders. The native engine does this automatically for you across `quarto render` invocations as long as you do not restart Quarto.
- Use Julia 1.10 or later, which has significantly faster package loading and reduces TTFX across the ecosystem.

!!! warning

    Typst looks for fonts on disk only. If you set `mainfont` in the YAML, make sure the font is installed where Typst can see it. `CairoMakie` has its own font fallback logic for axis labels and tick text, which is independent of Typst, so plot text and body text can drift apart visually. See [Tips & Tricks: Fonts](../crash-course/tips-and-tricks.md#fonts).

## Next step

To go beyond the YAML-level knobs (page size, fonts, margins, `include-in-header`) and build a reusable house style, move on to [Custom Typst format](custom-format.md).

!!! question

    Spotted something that does not render, or know a better pattern? [Feel free to open an issue](https://github.com/y-sunflower/typst-in-production/issues).
