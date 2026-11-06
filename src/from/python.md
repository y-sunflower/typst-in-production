---
title: Typst from Python
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from Python](./index.md) to fully understand it.

In Python, we can use [typst-py](https://github.com/messense/typst-py), maintained by [messense](https://github.com/messense). It provides bindings to the Typst compiler, so we can compile documents without installing the Typst CLI separately.

Please also note that Python integrates well with [Quarto](https://quarto.org/), which offers a convenient and highly customizable way to create reports with Typst. You can find a dedicated tutorial [here](../quarto/index.md).

## Installation

=== "uv"

      ```bash
      uv add typst
      ```

=== "pip"

      ```bash
      pip install typst
      ```

=== "pixi"

      ```bash
      pixi add typst-py
      ```

The package is called `typst` on PyPI and [`typst-py` on conda-forge](https://anaconda.org/conda-forge/typst-py), which Pixi uses by default.

## Usage

Create a file named `file.typ`:

```typst title="file.typ"
= Hello from Python

This document was compiled from Python.
```

Then use the [`compile()` function](https://typst-py.readthedocs.io/en/latest/#typst.compile) to create a PDF:

```python title="main.py"
import typst

typst.compile("file.typ", output="file.pdf")
```

If we omit `output`, `compile()` returns the PDF as Python `bytes` instead of writing a file.

## Passing data from Python to Typst

We can pass info from Python to Typst using the `sys_inputs` argument. Its keys and values must be strings, so we serialize lists and dictionaries with `json.dumps()`:

```python title="main.py"
import json
import typst

humans = [{"name": "Joseph", "age": 25}, {"name": "Justine", "age": 24}]
sys_inputs = {"humans": json.dumps(humans)}

typst.compile(input="file.typ", output="file.pdf", sys_inputs=sys_inputs)
```

On the Typst side, we can read those inputs with:

```typst title="file.typ"
#let humans = json(bytes(sys.inputs.humans))

#for human in humans [
      #human.name is #human.age years old. \
]
```

Being able to pass variables from Python to Typst lets us connect our Python logic directly to the PDF output rendered for the user.

## Specifying font paths

Pass a list of font directories through [`font_paths`](https://typst-py.readthedocs.io/en/latest/#typst.compile). For example, put the Roboto `.ttf` or `.otf` files in a `fonts` directory and compile with:

```python title="main.py"
import typst

typst.compile("file.typ", output="file.pdf", font_paths=["fonts"])
```

Select the font by its family name in the document:

```typst title="file.typ"
#set text(font: "Roboto")

= Hello with a custom font
```

`font_paths` takes directories containing font files. Relative paths such as `"fonts"` resolve from Python's current working directory; absolute paths work too. Adding a directory makes its fonts available, and `text(font: ...)` selects the family to use.

System and bundled fonts are available by default. Pass `ignore_system_fonts=True` to skip system fonts while keeping bundled fonts and those in `font_paths`. If you reuse a `typst.Compiler`, set `font_paths` on its constructor: `typst.Compiler(font_paths=["fonts"])`.

## Other resources

`typst-py` is probably the most useful tool to combine Typst and Python, but other projects are worth mentioning as they can solve different use cases:

- [`pyrunner`](https://typst.app/universe/package/pyrunner/): a Typst package that lets you run Python code (stdlib only) inside Typst.

````typst
#import "@preview/pyrunner:0.3.0" as py

#let compiled = py.compile(
```python
def find_emails(string):
    import re
    return re.findall(r"\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b", string)

def sum_all(*array):
    return sum(array)
```)

#let txt = "My email address is john.doe@example.com and my friend's email address is jane.doe@example.net."

#py.call(compiled, "find_emails", txt)
#py.call(compiled, "sum_all", 1, 2, 3)
````

- [`pypst`](https://krokotsch.eu/pypst/): a Python package designed to generate Typst code in Python.

```python
import pypst

heading = pypst.Heading("My Heading", level=2)
print(heading.render()) # prints: "== My Heading"
```

- [`typstpy`](https://github.com/beibingyangliuying/python-typst): a Python package to generate Typst code, similar to `pypst`.

```python
from typstpy.std.visualize import circle

circle("[Hello, world!]", radius="10pt")
```

Output is: `#circle([Hello, world!], radius: 10pt)`.

<br>

!!! tip

      If you want to learn more about Python and Typst, check out [the FastAPI and Typst tutorial](../projects/python-fastapi.md).

<br>

!!! question

      Know of other projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
