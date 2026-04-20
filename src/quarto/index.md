---
title: Quarto
---

Quarto is an authoring system that lets you define document content in one place.
In practice, you create a `.qmd` (or `.ipynb`) file that combines Markdown and code cells (R, Python, Julia, or Observable).

````markdown
---
title: Quarto document
format: typst
---

## This is a heading

And this is a paragraph...

```{python}
print("hello world")
```
````

You can then use the Quarto CLI to render this file to an HTML document:

```bash
quarto render file.qmd
```

This command creates `file.pdf`:

![Rendered PDF output](../../images/quarto-minimal.png)

## Core features

Quarto is especially useful for three main reasons:

=== "Export formats"

    Write once in a single source format (Markdown + code), then export to multiple output formats (HTML, PDF, Word, Markdown).

    ![Multiple export formats in Quarto](../../images/quarto-2.png)

=== "Parameters"

    Quarto documents can be parameterized.
    For example, your file can define a parameter (such as a country) and reuse it in code.
    This lets you maintain one document and render many variants (for example, one per country).

    ````md
    ---
    title: Parameterized document
    params:
      food: cookies
    ---

    ## A parameterized document

    ```{r}
    print("Parameter is:\n")
    print(params$food)
    ```
    ````

    ![Parameterized rendering example](../../images/quarto-parameterized.png)

=== "Other"

    Quarto also provides extensive support for styling, templates, extensions, and interactivity.
    Its community is large and active.
    To explore more, visit the [official website](https://quarto.org/).

## Quarto and Typst

When the YAML front matter contains `format: typst`, Quarto uses Typst as the PDF backend instead of LaTeX.
The render pipeline has three stages:

1. Your `.qmd` file runs the computation engine (knitr for R, jupyter with the Python kernel by default for Python, or the native Julia engine), producing a plain Markdown file with figures, tables, and computed values already inlined.
2. Pandoc converts that Markdown into a `.typ` source file, using a small set of Quarto-provided Typst partials (`typst-template.typ`, `typst-show.typ`, `template.typ`, `page.typ`, `definitions.typ`, `numbering.typ`, `notes.typ`, `biblio.typ`).
3. Typst compiles the `.typ` file into the final PDF.

You will meet those partial filenames again in [Custom Typst format](custom-format.md), where we replace them with our own.

Here is the smallest possible Quarto document that targets Typst:

```md title="report.qmd"
---
title: My first Typst report
format: typst
---

Hello from Quarto and Typst.
```

Render it with:

```bash
quarto render report.qmd
```

### How data flows from code to Typst

Three mechanisms carry values from your code cells into the final Typst PDF.
They behave the same way regardless of language.

!!! warning

    The three curly-brace form `` ```{python} `` declares an **executable** cell.
    A plain `` ```python `` block is a **display-only** code sample that is never run.
    Mixing the two up is the single most common source of "why is my code not running?" in Quarto.

#### Inline expressions

Inline backticks with a language prefix run an expression and splice its value into prose:

```md
The answer is `{python} 6 * 7`.
```

The rendered PDF contains the literal text "The answer is 42." with no trace of the code.

#### Figures

Any plot emitted by a code cell becomes a Typst `figure` block.
Use the usual Quarto code cell options inside the cell:

````md
```{python}
#| label: fig-sales
#| fig-cap: Quarterly sales by region.
#| fig-alt: Bar chart comparing quarterly sales across four regions.
#| fig-format: svg
#| fig-dpi: 300

make_sales_plot()
```
````

Cross-reference the figure with `@fig-sales`, and Quarto resolves it as a Typst reference in the PDF.
The `fig-` prefix on the label is what tells Quarto to treat the output as a cross-referenceable figure; `tbl-` does the same for tables.

!!! tip

    For `format: typst`, prefer `fig-format: svg` where your plotting library supports it.
    Vector output stays sharp at every zoom level and keeps the PDF small.
    Raster fallbacks look fuzzy unless you also raise `fig-dpi`.

#### Tables

Tables are a little more nuanced.
Some packages produce **native Typst code** that Quarto drops straight into the document.
Others emit **HTML**, which Quarto processes into a proper Typst table automatically.
Either way, the table in the PDF contains real text, not a flat image.
Which package does what is language-specific and is covered on each language page.

### Parameters

Parameters let you produce many PDFs from a single source by passing different values at render time.
Two mechanisms exist, and which one you use depends on the computation engine.

=== "R (knitr) and Julia (native engine)"

    Declare a `params:` block in the YAML.
    Under `knitr` (R), the values are available as `params$region`.
    Under the native Julia engine, each entry becomes a top-level constant named after its key.

    ````md title="report.qmd"
    ---
    title: Regional sales report
    format: typst
    params:
      region: North
      year: 2026
    ---
    ````

=== "Python (jupyter)"

    The jupyter engine does **not** use the YAML `params:` block.
    Instead, tag a code cell as `parameters` and assign default values inside it.
    At render time, Quarto uses [papermill](https://papermill.readthedocs.io/) to override those values with whatever you pass on the command line.

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
    ````

Both mechanisms share the same command-line override syntax.
Render with a different set of values without editing the file:

```bash
quarto render report.qmd -P region:South -P year:2025
```

!!! note

    This is the Quarto-level equivalent of the `sys.inputs` mechanism shown on the [From languages](../from/index.md) pages. Both give you the same outcome (one source, many PDFs). Quarto's parameters are higher level and integrate with the computation engine, while `sys.inputs` is lower level and runs without Quarto. Pick based on whether you want the rest of Quarto's machinery or just a direct Typst compile.

### Typst knobs from the YAML

A handful of YAML options under `format: typst:` map directly onto Typst set rules.
Setting them is the fastest way to customise output without touching a single `.typ` file.

| YAML option         | Purpose                                                                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `papersize`         | Any Typst paper size name, for example `a4`, `us-letter`, `presentation-16-9`.                                                                          |
| `margin`            | Page margins, with sub-options `x`, `y`, `top`, `bottom`, `left`, `right`.                                                                              |
| `mainfont`          | The main text font. Typst must be able to find the font locally.                                                                                        |
| `fontsize`          | Base font size, for example `11pt`.                                                                                                                     |
| `include-in-header` | Path to a `.typ` file whose contents are inserted into the generated `.typ` before the body. Useful for custom set rules without building an extension. |
| `template-partials` | A list of partial filenames that override Quarto's defaults for one document. This is how you tweak `typst-show.typ` without creating a full extension. |
| `keep-typ`          | When `true`, keeps the intermediate `.typ` file next to the PDF after rendering. Useful for inspecting the generated Typst source.                      |

A concrete example that sets page size, font, and drops in a custom heading colour:

```md title="report.qmd"
---
title: Styled report
format:
  typst:
    papersize: a4
    mainfont: Inter
    fontsize: 11pt
    include-in-header:
      - text: |
          #show heading.where(level: 1): set text(fill: rgb("#2a9d8f"))
---
```

!!! tip

    Typst can only use fonts it can find on disk. If you set `mainfont` to something unusual, install the font locally or bundle it alongside the project and set `TYPST_FONT_PATHS` accordingly. See [Tips & Tricks: Fonts](../crash-course/tips-and-tricks.md#fonts).

### Brand.yml

Quarto's `_brand.yml` file lets you centralise brand colours, typography, and logos in one place and reuse them across formats.
It is supported for `format: typst`, so the same `_brand.yml` can drive your website, your slide deck, and your Typst PDFs.

Inside the generated Typst, the brand colours are exposed as a dictionary named `brand-color` that you can reach from raw Typst blocks or from custom partials.
See the [official brand.yml documentation](https://quarto.org/docs/authoring/brand.html) for the complete schema.

!!! tip

    For a worked example of threading `_brand.yml` colours and fonts, in R (with `ggplot2` figures and `gt` tables) and in Python (with `plotnine` figures and `great_tables` tables), see the blog post [Brand-aware figures and tables in Quarto + Typst](https://mickael.canouil.fr/posts/2026-04-15-quarto-brand-figures-tables/).

When the YAML-level knobs stop being enough, the next step is overriding a partial or shipping your own format extension.
That is what [Custom Typst format](custom-format.md) is about.

## Pick your language

Now that the concepts are out of the way, pick the language you work in and walk through a full parameterised Typst report end to end:

- [Quarto and R](R.md) with the knitr engine, `ggplot2`, and `gt`.
- [Quarto and Python](python.md) with the jupyter engine, `plotnine`, and `great_tables`.
- [Quarto and Julia](julia.md) with QuartoNotebookRunner.jl, `CairoMakie`, and `SummaryTables.jl`.

When you are ready to move beyond the built-in format, head to [Custom Typst format](custom-format.md).
