---
title: Quarto and R
---

!!! tip

    The concepts behind `format: typst` (render pipeline, parameters, figures, tables) live on the [Quarto overview page](index.md).
    This page only covers the R-specific pieces.
    If you would rather drive Typst from R without Quarto, see [Typst from R](../from/R.md) instead.

R is the only one of the three supported languages where Quarto's default engine is first-party and non-Jupyter.
That engine is [`knitr`](https://yihui.org/knitr/), which runs your R cells (or any language registered and supported by `knitr`) directly in an R session with no kernel to manage.

## Prerequisites

You need three things installed locally:

- [Quarto CLI](https://quarto.org/docs/get-started/).
- R itself.
- The `knitr` package.

```r
install.packages("knitr")
```

For the rest of the tutorial we also need `ggplot2`, `dplyr`, and `gt`:

```r
install.packages(c("ggplot2", "dplyr", "gt"))
```

## A minimal Typst document

Create a file called `report.qmd` with the following contents:

````md title="report.qmd"
---
title: My first Typst report
format: typst
---

This report was written in Quarto and compiled with Typst.

```{r}
x <- c(1, 2, 3, 4, 5)
mean(x)
```
````

Render it:

```bash
quarto render report.qmd
```

Quarto runs the R cell through `knitr`, hands the resulting Markdown to Pandoc, and compiles the final PDF with Typst.
You should now have a `report.pdf` next to your source file.

![Rendered PDF from the minimal R example.](../../images/quarto-minimal-R.png)

## Building a small report

We now grow that skeleton into a real, parameterised sales report.
Each step below is a small addition to the previous `report.qmd`.

### Step 1: add parameters and a setup cell

We parameterise the report by region and year, and we add an invisible setup cell that loads packages and reads the parameters once:

````md title="report.qmd"
---
title: Regional sales report
format: typst
params:
  region: North
  year: 2026
---

```{r setup}
#| include: false

library(ggplot2)
library(dplyr)
library(gt)

region <- params$region
year <- params$year
```
````

The `#| include: false` option hides the setup cell from the output but still runs it.

!!! note

    Under `knitr`, parameters defined in the YAML `params:` block are available inside any R cell as a list:`params$<name>` or `params[["<name>"]]`.
    You do not need to declare anything in the cell itself.

### Step 2: computed values inline in prose

Add a short introduction that quotes the parameters directly in the text:

```md
## Overview

This report covers the **`{r} params$region`** region for the year **`{r} params$year`**.
Values below are quarterly totals in thousands.
```

The `` `{r} ...` `` inline backticks evaluate an R expression and splice its result into the paragraph.
No figure, no cell, just prose with computed values.

### Step 3: a figure with `ggplot2`

Add a code cell that builds the quarterly sales chart:

````md
## Sales by quarter

```{r}
#| label: fig-sales
#| fig-cap: !expr paste("Quarterly sales for", region, "in", year, ".")
#| fig-alt: Bar chart of quarterly sales, one bar per quarter.
#| fig-format: svg
#| fig-width: 6
#| fig-height: 3.5

sales <- data.frame(
  quarter = c("Q1", "Q2", "Q3", "Q4"),
  total = c(120, 135, 158, 172)
)

ggplot(sales) +
  aes(x = .data$quarter, y = .data$total) +
  geom_col(fill = "#2a9d8f") +
  labs(x = NULL, y = "Sales (k)") +
  theme_minimal(base_size = 11)
```

@fig-sales shows steady growth across the year.
````

Three things to notice:

- `fig-format: svg` keeps the plot as a vector image inside the PDF.
  This is almost always what you want for `format: typst`.
- `fig-cap` uses `!expr` so the caption itself can reference parameters.
  Plain string captions also work.
- The cross-reference `@fig-sales` is resolved by Quarto as a Typst reference, so the text "Figure 1" and the page number are correct.
  The `fig-` prefix on the label is what triggers cross-referencing; `tbl-` does the same for tables.

### Step 4: a table with `gt`

`gt` emits **HTML** when it detects a Typst render context, and Quarto converts that HTML into a proper Typst table automatically.
Add a table cell below the figure:

````md
## Sales table

```{r}
#| label: tbl-sales
#| tbl-cap: !expr paste("Quarterly totals for", region, ".")

sales |>
  gt::gt() |>
  gt::cols_label(quarter = "Quarter", total = "Sales (k)") |>
  gt::fmt_number(columns = "total", decimals = 0) |>
  gt::tab_options(table.width = gt::pct(60))
```

@tbl-sales lists the same numbers shown in @fig-sales.
````

Because Quarto converts `gt`'s HTML output into real Typst table code (not an image), you get proper page breaks and copy-paste text out of the box.

!!! note

    If you prefer a lighter alternative, [`tinytable`](https://vincentarelbundock.github.io/tinytable/) and [`typstable`](https://freierson.github.io/typstable/) both produce native Typst output.
    Use `tinytable::tt(sales)` or `typstable::typst_table(sales)` in place of the `gt` chain above.

### Step 5: render with a different parameter

The whole point of `params:` is that a second render with a different value produces a different PDF from the same source:

```bash
quarto render report.qmd -P region:South -P year:2025
```

The title, the inline prose, the figure caption, and the table caption all update to match.

![Rendered PDF from the parameterised R report.](../../images/quarto-report-R.png)

## Gotcha: fonts inside `ggplot2` plots

Setting `mainfont: Inter` in the YAML tells Typst to render the document body in Inter.
It has **no effect** on text drawn inside a `ggplot2` plot, because that text is rasterised (or vectorised for SVG) by R's graphics device using R's own font stack.

If plot text looks nothing like the surrounding body text, the usual fix is to switch to the [`ragg`](https://ragg.r-lib.org/) device, install the matching font on the system, and set the family explicitly:

```r
library(ragg)
library(ggplot2)

ggplot(sales) +
  aes(x = .data$quarter, y = .data$total) +
  geom_col(fill = "#2a9d8f") +
  theme_minimal(base_size = 11, base_family = "Inter")
```

Then tell Quarto to use `ragg` for PNG and SVG figures by setting `dev: ragg_png` in the YAML, or configure it globally in a project-level `_quarto.yml`.

!!! warning

    Typst looks for fonts on disk only.
    Whatever font you pick for `mainfont`, make sure it is installed where both R (via `ragg`) and Typst can see it.
    See [Tips & Tricks: Fonts](../crash-course/tips-and-tricks.md#fonts) for the details.

## Next step

To go beyond the YAML-level knobs (page size, fonts, margins, `include-in-header`) and build a reusable house style, move on to [Custom Typst format](custom-format.md).

If you would rather bypass Quarto entirely and drive Typst from R directly, see [Typst from R](../from/R.md).

!!! question

    Spotted something that does not render, or know a better pattern? [Feel free to open an issue](https://github.com/y-sunflower/typst-in-production/issues).
