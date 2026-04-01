---
title: Tips & Tricks
---

On this page you'll find various info and techniques about Typst that are mostly too small to be inside their own lessons.

## Fonts

Typst works exclusively with fonts that are available locally. By default, it will just look for fonts **installed** on your system, but you can specify additional font paths with either:

- `--font-path` argument in the CLI. For example, you would do: `typst compile file.typ --font-path path/to/fonts/`
- `TYPST_FONT_PATHS` environment variable. It should specify a path to look for fonts.

!!! note

        Typst will not work outside of your root directory (e.g. where your `.typ` file is), so make sure to include additional fonts in a place where Typst has access.

Also, you can see which fonts Typst has access to by running:

```
typst fonts
```

In my case, the head of the output is:

```
Academy Engraved LET
Adobe Caslon Pro
ADT Slab Numeric
ADT Slab Soft Numeric
Al Bayan
Al Bayan PUA
Al Nile
Al Nile PUA
Al Tarikh
...
```

You can ensure Typst **never** looks for fonts installed on your machine using the `--ignore-system-fonts` parameter. The main usage of this is when you specify fonts in a local directory and want a clear warning message if Typst is unable to use the right font.

In practice, it is recommended that you manage the font files you need using [Git LFS (Large File Storage)](https://git-lfs.com/), a Git extension for managing large or binary files.

## Remote image path

If you come from web development, you might have the habit of specifying image paths as remote URLs (e.g., `https://example.com/image.png`). But, for security reasons, Typst will **not** let you do so and requires the image to be available locally.

Similarly to fonts, the image path must be relative to your Typst file and not in a parent directory. A good architecture would be:

```
├── images/
│ ├── logo.png
│ └── design.png
├── fonts/
│ ├── MyFont.ttf
│ └── MyFont-Bold.ttf
└── file.typ
```

<br>
<br>

!!! Question

    Having questions? Feedback? [Feel free to ask](https://github.com/y-sunflower/typst-in-production/issues)!
