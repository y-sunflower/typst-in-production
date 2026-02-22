---
title: Typst from Python
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from Python](./index.md) to fully understand it.

In Python, the recommended binding to use is [typst-py](https://github.com/messense/typst-py), maintained by [messense](https://github.com/messense), a [Maturin](https://www.maturin.rs/) developer (the software that allows Python and Rust to communicate), which is a very good thing.

Please also note that Python integrates well with [Quarto](https://quarto.org/), which offers a convenient and highly customizable way to create reports with Typst. You can find a dedicated tutorial [here](/../quarto/index.md).

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
      pixi add typst
      ```

## Usage

It mainly offers a `compile()` function that we can use like this:

```python title="main.py"
import typst

typst.compile("file.typ", output="file.pdf")
```

We can pass info from Python to Typst using the `sys_inputs` argument in a JSON-like manner:

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

By being able to pass variables from Python to Typst, it enables us to connect our Python logic directly to the PDF output that will be rendered to the user.

## Example with FastAPI

Here is an example that creates a FastAPI `/report` endpoint with a `color` argument that returns a PDF report made with Typst, relying on that parameter for styling.

First, we create a basic Typst file:

```typst title="file.typ"
#let col = json(bytes(sys.inputs.color))
#set page(fill: rgb(col), width: 10cm, height: 5cm)

= Dynamic Typst report made with Python
```

Then a minimalist FastAPI app:

```python title="main.py"
from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import FileResponse
import typst


app = FastAPI()

@app.get("/report")
def report(color: str):
      path_typst = "file.typ"
      path_pdf = "file.pdf"

      sys_inputs = {"color": json.dumps(color)}

      typst.compile(
            path_typst,
            output=path_pdf,
            sys_inputs=sys_inputs,
      )

      return FileResponse(Path(report_path))
```

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

- [`pyst`](https://krokotsch.eu/pypst/): a Python package designed to generate Typst code in Python.

```python
import pypst

heading = pypst.Heading("My Heading", level=2)
print(heading.render()) # prints: "== My Heading"
```

- [`typstpy`](https://github.com/beibingyangliuying/python-typst): a Python package to generate Typst code, similar to `pyst`.

```python
from typstpy.std.visualize import circle

circle("[Hello, world!]", width="100%", radius="10pt")
```

Output is: `#circle([Hello, world!], width: 100%, radius: 10pt)`.

<br>

!!! question

      Know of other projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
