---
title: Typst from Rust
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from Rust](./index.md) to fully understand it.

In Rust, Typst can be used in a very "native" way because Typst itself is built in Rust.

The most practical entry point today is [`typst-as-lib`](https://crates.io/crates/typst-as-lib), a community crate that wraps the lower-level Typst internals and gives a simpler API for report generation.

## Installation

=== "Minimal dependencies"

      ```bash
      cargo add typst-as-lib typst-pdf
      ```

=== "Typed input helpers"

      ```bash
      cargo add typst derive_typst_intoval
      ```

## Usage

The usual flow in Rust is:

1. Build a `TypstEngine` from a Typst template
2. Compile to a Typst document
3. Convert that document to PDF bytes with `typst-pdf`
4. Write the PDF file

```rust title="main.rs"
use std::fs;
use typst_as_lib::TypstEngine;

static TEMPLATE: &str = include_str!("file.typ");

fn main() {
    let engine = TypstEngine::builder().main_file(TEMPLATE).build();

    let doc = engine
        .compile()
        .output
        .expect("Typst compilation failed");

    let pdf = typst_pdf::pdf(&doc, &Default::default())
        .expect("PDF generation failed");

    fs::write("file.pdf", pdf).expect("Could not write file.pdf");
}
```

## Passing data from Rust to Typst

We can pass structured data from Rust into Typst and let the template render dynamic sections.

```rust title="main.rs"
use derive_typst_intoval::{IntoDict, IntoValue};
use typst::foundations::Dict;
use typst_as_lib::TypstEngine;

static TEMPLATE: &str = include_str!("file.typ");

#[derive(Clone, IntoValue, IntoDict)]
struct Human {
    name: String,
    age: i32,
}

#[derive(Clone, IntoValue, IntoDict)]
struct Input {
    humans: Vec<Human>,
}

impl From<Input> for Dict {
    fn from(value: Input) -> Self {
        value.into_dict()
    }
}

fn main() {
    let engine = TypstEngine::builder().main_file(TEMPLATE).build();

    let input = Input {
        humans: vec![
            Human {
                name: "Joseph".to_string(),
                age: 25,
            },
            Human {
                name: "Justine".to_string(),
                age: 24,
            },
        ],
    };

    let doc = engine
        .compile_with_input(input)
        .output
        .expect("Typst compilation failed");

    let pdf = typst_pdf::pdf(&doc, &Default::default())
        .expect("PDF generation failed");

    std::fs::write("file.pdf", pdf).expect("Could not write file.pdf");
}
```

On the Typst side:

```typst title="file.typ"
#let humans = json(bytes(sys.inputs.humans))

#for human in humans [
      #human.name is #human.age years old. \
]
```

By passing Rust data directly to Typst, your application logic and report rendering stay tightly connected.

## Example with Axum

Here is a minimalist `GET /report?color=%23f9f6f4` endpoint that compiles and returns a PDF. The `color` query parameter is injected into Typst input.

First, the Typst template:

```typst title="file.typ"
#let col = json(bytes(sys.inputs.color))

#set page(fill: rgb(col), width: 10cm, height: 5cm)

= Dynamic Typst report made with Rust
```

Then a small Axum server:

```rust title="main.rs"
use axum::{extract::Query, response::IntoResponse, routing::get, Router};
use derive_typst_intoval::{IntoDict, IntoValue};
use serde::Deserialize;
use typst::foundations::Dict;
use typst_as_lib::TypstEngine;

static TEMPLATE: &str = include_str!("file.typ");

#[derive(Deserialize)]
struct ReportParams {
    color: String,
}

#[derive(Clone, IntoValue, IntoDict)]
struct ReportInput {
    color: String,
}

impl From<ReportInput> for Dict {
    fn from(value: ReportInput) -> Self {
        value.into_dict()
    }
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/report", get(report));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();

    axum::serve(listener, app).await.unwrap();
}

async fn report(Query(params): Query<ReportParams>) -> impl IntoResponse {
    let engine = TypstEngine::builder().main_file(TEMPLATE).build();

    let doc = engine
        .compile_with_input(ReportInput {
            color: params.color,
        })
        .output
        .expect("Typst compilation failed");

    let pdf = typst_pdf::pdf(&doc, &Default::default())
        .expect("PDF generation failed");

    ([("content-type", "application/pdf")], pdf)
}
```

## Other resources

- [`typst`](https://crates.io/crates/typst): the official Typst compiler crate (low-level, powerful, less ergonomic for quick app integration).
- [`typst-pdf`](https://crates.io/crates/typst-pdf): PDF backend used to export compiled Typst documents to PDF bytes.
- [`typst-as-lib` examples](https://github.com/Relacibo/typst-as-lib/tree/main/examples): good reference for fonts, images, and structured inputs.

<br>

!!! question

      Know of other Rust projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
