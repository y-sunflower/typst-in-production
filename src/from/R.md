---
title: Typst from R
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from R](./index.md) to fully understand it.

In R, we can use [tynding](https://github.com/y-sunflower/tynding). It provides bindings to the Typst compiler, so we can compile documents directly from R without installing the Typst CLI separately.

Please also note that R integrates well with [Quarto](https://quarto.org/), which offers a convenient and highly customizable way to create reports with Typst. You can find a dedicated tutorial [here](../quarto/index.md).

## Installation

Install `tynding` from [R-universe](https://y-sunflower.r-universe.dev/tynding):

```R
install.packages(
  "tynding",
  repos = c("https://y-sunflower.r-universe.dev", "https://cloud.r-project.org")
)
```

R-universe provides binaries for supported platforms. If R installs from source, building the Rust backend requires a Rust toolchain and can take a few minutes.

## Usage

```R
library(tynding)

pdf_file <- 
  c(
    '#set document(title: "hello from tynding")',
    "= hello world",
    "this document was compiled from R."
  ) |>
  typst_write() |>
  typst_compile(output = "report.pdf")
```

`typst_write()` writes the markup to a `.typ` file and returns its path. `typst_compile()` compiles that file and returns the output path invisibly. If you already have a Typst file, compile it directly:

```R
typst_compile("file.typ", output = "file.pdf")
```

## Specifying font paths

Pass a font directory through [`font_path`](https://github.com/y-sunflower/tynding#features-overview). For example, put the Roboto `.ttf` or `.otf` files in a `fonts` directory, then select the family in your Typst markup:

```R
library(tynding)

markup <- c(
  '#set text(font: "Roboto")',
  "= Hello with a custom font"
)

typ_file <- typst_write(markup)
pdf_file <- typst_compile(
  typ_file,
  output = "report.pdf",
  font_path = "fonts"
)
```

`font_path` takes one directory containing font files. Relative paths such as `"fonts"` resolve from R's current working directory (`getwd()`); absolute paths work too. The `font` value in `text(...)` is the font's family name, such as `"Roboto"`.

System and bundled fonts are available by default. Pass `ignore_system_fonts = TRUE` to skip system fonts while keeping bundled fonts and those in `font_path`.

<br>

!!! question

      Know of other projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
