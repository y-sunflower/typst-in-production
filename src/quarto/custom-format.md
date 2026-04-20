---
title: Custom Typst format
---

The YAML-level knobs covered on the [Quarto overview](index.md#typst-knobs-from-the-yaml) (page size, fonts, margins, `include-in-header`) are enough for one-off reports. As soon as you want the **same look and feel** across many documents, a branded cover, custom heading rules, or reusable layout helpers, you need to reach for Quarto's partials and, eventually, a full format extension.

This page takes you from "I want to change one thing" to "I want to ship a reusable Typst format others can install".

## How Quarto's Typst output is built

When Quarto compiles a document with `format: typst`, it stitches the final `.typ` file together from a small set of **partials**. Each partial is a Typst file with a specific responsibility:

| Partial              | Responsibility                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------------- |
| `typst-template.typ` | Defines the top-level template function that lays out the page (title, body, margins, columns).   |
| `typst-show.typ`     | Holds the `#set` and `#show` rules applied to the document (heading colours, link styles, fonts). |
| `template.typ`       | The outer document wrapper that calls the template function and wires up the show rules.          |
| `page.typ`           | Configures the `page` function (paper size, margins, header/footer).                              |
| `definitions.typ`    | Definitions for Pandoc and Quarto features (block quotes, callouts, subfloats).                   |
| `numbering.typ`      | Heading and figure numbering configuration.                                                       |
| `notes.typ`          | Footnote and endnote rendering.                                                                   |
| `biblio.typ`         | Bibliography rendering.                                                                           |

Quarto ships a default version of each of these.
You can read the [default partials on GitHub](https://github.com/quarto-dev/quarto-cli/tree/main/src/resources/formats/typst/pandoc/quarto).
You can override any subset of them for a single document, and you can bundle your own versions into a format extension that others can install.

!!! note

    You do not have to override every partial, only the ones you want to change. Any partial you do not provide falls back to the Quarto default.

## Overriding a single partial in place

The fastest way to change the look of one document is to drop a modified partial next to it and register it via the `template-partials` YAML option.

Imagine we want every level 1 heading in a specific report to appear in teal. Create a `typst-show.typ` next to the `.qmd`:

```typst title="typst-show.typ"
#show heading.where(level: 1): set text(fill: rgb("#2a9d8f"))
```

Then wire it up in the document:

```md title="report.qmd"
---
title: Styled report
format:
  typst:
    template-partials:
      - typst-show.typ
---

## Overview

Body text goes here.
```

When Quarto renders `report.qmd`, it uses our `typst-show.typ` instead of the default one. Every other partial (template, page, definitions, notes, biblio) is still the Quarto default.

!!! tip

    To inspect the `.typ` file that Quarto generates (before Typst compiles it to PDF), add `keep-typ: true` under `format: typst:`.
    The file is written next to the output PDF and is invaluable when debugging partial overrides.

!!! tip

    `template-partials` accepts a list, so you can override several partials at once. Any file whose basename matches a known partial (`typst-show.typ`, `typst-template.typ`, `page.typ`, and so on) takes the place of Quarto's default for that name.

This approach is perfect for one-off tweaks. It stops scaling when:

- You want to reuse the same look across many reports in different directories.
- You want to bundle fonts, logos, or helper Typst modules alongside the partials.
- You want others to install your style with a single `quarto add` command.

At that point, it is time to promote the partials into a **format extension**.

## Promoting the partials into a format extension

Quarto ships a scaffolding command that creates the skeleton of a format extension:

```bash
quarto create extension format:typst
```

You will be prompted for an extension name. For this page we will call it `teal-report`.

The command creates a directory tree roughly like this (exact contents vary between Quarto versions):

```text
teal-report/
├── README.md
├── template.qmd
└── _extensions/
    └── teal-report/
        └── _extension.yml
```

`template.qmd` is a pre-populated starter document whose YAML already references the custom format (e.g. `format: teal-report-typst`).
It serves two purposes: smoke testing during development, and giving users a ready-made starting point when they install the extension with `quarto use template`.
The real work lives under `_extensions/teal-report/`.

Edit `_extension.yml` so that it declares a Typst format and points at your partials:

```yaml title="_extensions/teal-report/_extension.yml"
title: Teal Report
author: Your Name
version: 0.1.0
quarto-required: ">=1.7.0"
contributes:
  formats:
    typst:
      template-partials:
        - typst-template.typ
        - typst-show.typ
      mainfont: Inter
      fontsize: 11pt
      papersize: a4
```

Now add the two partials next to `_extension.yml`. Start with a minimal `typst-show.typ`:

```typst title="_extensions/teal-report/typst-show.typ"
#let teal = rgb("#2a9d8f")

#show heading.where(level: 1): set text(fill: teal, weight: "bold")
#show heading.where(level: 2): set text(fill: teal)
#show link: set text(fill: teal)
```

And a minimal `typst-template.typ` that wraps the document body:

```typst title="_extensions/teal-report/typst-template.typ"
#let article(
  title: none,
  authors: (),
  body,
) = {
  set document(title: title)
  set page(numbering: "1", number-align: center)

  if title != none {
    align(center, text(size: 20pt, weight: "bold", title))
    v(1em)
  }

  body
}
```

The exact template function signature follows the conventions documented in the [Quarto Typst reference](https://quarto.org/docs/reference/formats/typst.html). If you override `typst-template.typ`, check the signature your version of Quarto expects so that Quarto can call your function with the right arguments.

## Using the extension from a document

With the extension in place, any Quarto document inside the parent directory can use it by referencing the format as `<org-or-user>-<name>-typst`. If the extension is in the same folder as your `.qmd` (or in any ancestor up to the project root), Quarto finds it automatically.

```md title="report.qmd"
---
title: A report in teal
format:
  teal-report-typst:
    papersize: a4
---

## Overview

Body text goes here, with teal headings and teal links.
```

Any YAML option you pass under `teal-report-typst:` is merged with the defaults declared in `_extension.yml`, so individual documents can still tweak the page size, font, or margins without editing the extension.

## Publishing the extension

Once the extension renders cleanly on its bundled `template.qmd`, you can publish it so that others install it with a single command. The minimum viable workflow is:

1. Commit the extension directory to a public GitHub repository.
2. Tag a release.
3. Point users at `quarto add <user>/<repo>`.

After running that command, the consumer has `_extensions/<user>/<repo>/` inside their project and can use `format: <repo>-typst` in the same way you used it locally.

For a full walk-through, including distribution-time versioning and pre-releases, see the [Quarto extensions documentation](https://quarto.org/docs/extensions/).

## Templates versus formats

There is a second, adjacent feature people confuse with format extensions: **templates**. Both live under `_extensions/`, but they solve different problems.

- A **format extension** adds a new `format:` value to the YAML. The consumer stays in control of the document, the extension just controls the output style. This is what we built above.
- A **template** is a pre-populated `.qmd` (or `.qmd` plus assets) that you scaffold a new project from using `quarto use template <user>/<repo>`. The consumer then edits that `.qmd` as if they had typed it themselves.

Rule of thumb: if you want to **style** other people's documents, publish a format extension. If you want to **give them a starting document** with your style already baked in, publish a template. Templates often embed a format extension under the hood so that the starting document already references the right style.

## Next steps

Format extensions are the right level for most reusable Typst styling on top of Quarto. A few directions to explore next:

- Bundle fonts and logos alongside the partials. Quarto's local-only font rules still apply, see [Tips & Tricks: Fonts](../crash-course/tips-and-tricks.md#fonts).
- Add accessibility metadata to your template. See [PDF accessibility](../pdf-accessibility.md) for the basics.
- Look at real-world examples in the [Example projects](../projects/index.md) section.

!!! question

    Built an interesting Typst format extension you would like mentioned here? [Feel free to open an issue](https://github.com/y-sunflower/typst-in-production/issues).
