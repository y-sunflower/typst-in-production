---
title: Quarto and Python
---

!!! tip

    The concepts behind `format: typst` (render pipeline, figures, tables, YAML knobs) live on the [Quarto overview page](index.md). This page only covers the Python-specific pieces. If you would rather drive Typst from Python without Quarto, see [Typst from Python](../from/python.md) instead.

Quarto runs Python cells through the **jupyter** engine, which talks to a Python kernel via the Jupyter protocol. You do not have to launch Jupyter yourself, Quarto manages the kernel for each render.

## Prerequisites

You need four things installed locally:

- [Quarto CLI](https://quarto.org/docs/get-started/).
- Python (3.11 or newer recommended).
- `jupyter` (Quarto uses it to run Python cells) and `papermill`.
- The packages used in the tutorial: `plotnine`, `polars`, and `great_tables`.

=== "uv"

    ```bash
    uv init
    uv add jupyter plotnine polars great_tables papermill
    ```

=== "pip"

    ```bash
    pip install jupyter plotnine polars great_tables papermill
    ```

!!! note

    Quarto needs `jupyter` to discover the Python kernel. If you are inside a virtual environment, make sure Quarto picks up that environment's kernel. `quarto check jupyter` prints the kernel Quarto actually sees.

## A minimal Typst document

Create a file called `report.qmd` with the following contents:

````md title="report.qmd"
---
title: My first Typst report
format: typst
---

This report was written in Quarto and compiled with Typst.

```{python}
xs = [1, 2, 3, 4, 5]
sum(xs) / len(xs)
```
````

Render it:

```bash
quarto render report.qmd
```

Quarto starts a Python kernel, runs the cell, hands the resulting Markdown to Pandoc, and compiles the final PDF with Typst. You should now have a `report.pdf` next to your source file.

![Rendered PDF from the minimal Python example.](../../images/quarto-minimal-python.png)

## Building a small report

We now grow that skeleton into a real, parameterised sales report. Each step below is a small addition to the previous `report.qmd`.

### Step 1: add a parameters cell and a setup cell

Python with the jupyter engine does **not** use the YAML `params:` block that R and Julia use.
Instead, you tag a cell as `parameters`, assign default values inside it, and Quarto uses [papermill](https://papermill.readthedocs.io/) to override those values at render time when you pass `-P` on the command line.

````md title="report.qmd"
---
title: Regional sales report
format: typst
---

```{python}
#| tags: [parameters]

region: str = "North"
year: int = 2026
```

```{python}
#| include: false

import polars as pl
from plotnine import ggplot, aes, geom_col, labs, theme_minimal
from great_tables import GT
```
````

The `#| include: false` option on the import cell hides it from the output but still runs it.

### Step 2: computed values inline in prose

Add a short introduction that quotes the parameters directly in the text:

```md
## Overview

This report covers the **`{python} region`** region for the year
**`{python} year`**. Values below are quarterly totals in thousands.
```

The `` `{python} ... ` `` inline backticks evaluate a Python expression and splice its result into the paragraph.

### Step 3: a figure with `plotnine`

Add a code cell that builds the quarterly sales chart:

````md
## Sales by quarter

```{python}
#| label: fig-sales
#| fig-cap: Quarterly sales for the selected region.
#| fig-alt: Bar chart of quarterly sales, one bar per quarter.
#| fig-format: svg
#| fig-width: 6
#| fig-height: 3.5

sales = pl.DataFrame({
    "quarter": ["Q1", "Q2", "Q3", "Q4"],
    "total": [120, 135, 158, 172],
})

(
    ggplot(sales)
    + aes(x="quarter", y="total")
    + geom_col(fill="#2a9d8f")
    + labs(x="", y="Sales (k)")
    + theme_minimal(base_size=11)
)
```

@fig-sales shows steady growth across the year.
````

Three things to notice:

- `fig-format: svg` keeps the plot as a vector image inside the PDF. This is almost always what you want for `format: typst`.
- The chart expression is wrapped in parentheses so you can write it across multiple lines without a trailing backslash.
- The cross-reference `@fig-sales` is resolved by Quarto as a Typst reference, so the text "Figure 1" and the page number are correct.
  The `fig-` prefix on the label is what triggers cross-referencing; `tbl-` does the same for tables.

### Step 4: a table with `great_tables`

`great_tables` emits **HTML** when rendered inside a `format: typst` document, and Quarto converts that HTML into a proper Typst table automatically.
Add a table cell below the figure:

````md
## Sales table

```{python}
#| label: tbl-sales
#| tbl-cap: Quarterly totals for the selected region.

(
    GT(sales)
    .cols_label(quarter="Quarter", total="Sales (k)")
    .fmt_number(columns="total", decimals=0)
)
```

@tbl-sales lists the same numbers shown in @fig-sales.
````

Because Quarto converts `great_tables`' HTML output into real Typst table code (not an image), you get proper page breaks and copy-paste text out of the box.

### Step 5: render with a different parameter

The whole point of the parameters cell is that a second render with different values produces a different PDF from the same source:

```bash
quarto render report.qmd -P region:South -P year:2025
```

The inline prose updates to match. You can add conditional logic (different filters, different chart titles) in your cells, and every render will reflect the current values.

![Rendered PDF from the parameterised Python report.](../../images/quarto-report-python.png)

## Gotcha: fuzzy figures in the PDF

Jupyter's default image format for inline figures is a PNG at the kernel's default DPI, which looks fine in a notebook and fuzzy in a Typst PDF. Two fixes, usually applied together:

1. Set `fig-format: svg` on any cell whose plot supports vector output. `plotnine` does. This is what the tutorial above uses.
2. For raster-only plots, raise `fig-dpi` to 200 or 300.

You can set either option globally in the YAML rather than per cell:

```md title="report.qmd"
---
title: Regional sales report
format:
  typst:
    fig-format: svg
    fig-dpi: 300
---
```

## Next step

To go beyond the YAML-level knobs (page size, fonts, margins, `include-in-header`) and build a reusable house style, move on to [Custom Typst format](custom-format.md).

If you would rather bypass Quarto entirely and drive Typst from Python directly, see [Typst from Python](../from/python.md) or the end-to-end [FastAPI example](../projects/python-fastapi.md).

!!! question

    Spotted something that does not render, or know a better pattern? [Feel free to open an issue](https://github.com/y-sunflower/typst-in-production/issues).
