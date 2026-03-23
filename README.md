## Typst in Production: the complete guide

[_Typst in Production_](https://typst-in-production.com/) is a practical guide to building, automating, and deploying PDFs with Typst. It will teach you everything you need to know, such as:

- Learn how to use Typst, from basic examples to complex templates
- Using Typst in other programming languages such as Python, R, Rust and JavaScript
- How to make fully accessible PDFs
- _and much more!_

<br><br>

## Contribution

### Get started

All kind of contributions are more than welcomed! The website is built using [zensical](https://zensical.org/). All the content lives in the `src/` directory in markdown files.

### Setup

- Fork and clone the repo

- Optional but recommended: install [uv](https://docs.astral.sh/uv/) and [just](https://github.com/casey/just)

- Install dependencies

```bash
uv sync
```

- Preview locally:

```bash
just preview
```

If you want to add examples, add your Typst files in `src/examples/` and then compile with:

```bash
just typst
```
