## Typst in Production: the complete guide

_Typst in Production_ is a practical guide to building, automating, and deploying PDFs with Typst.

It will teach you everything you need to know, such as:

- Typst in other programming languages
- Create parametrized templates
- and much more!

<br><br>

## Contribution

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
