---
title: Typst from Rust
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from Rust](./index.md) to fully understand it.

Typst is written in Rust, so we can use its compiler directly through the official [`typst`](https://docs.rs/typst/0.15.1/typst/) crate. There is no need to install the Typst command line tool or call an external process.

To do this, we implement Typst's [`World`](https://docs.rs/typst/0.15.1/typst/trait.World.html) trait. A world provides everything the compiler needs: the standard library, input values, source files, fonts, and the current date.

## Installation

The examples below use **Typst 0.15.1**, which requires **Rust 1.92 or newer**. Keep the Typst crates on the same version, since their APIs can change between releases.

Create a project and add the dependencies:

```bash
cargo new typst-report
cd typst-report
cargo add typst@=0.15.1 typst-layout@=0.15.1 typst-pdf@=0.15.1
cargo add typst-kit@=0.15.1 --features datetime,embedded-fonts,system-files,system-downloader
```

The `typst` crate compiles the document, `typst-layout` provides the paged document type, and `typst-pdf` exports it to PDF. The official `typst-kit` crate supplies file loading, package downloads, embedded fonts, and date handling for our world.

## Providing a world

Create `src/compiler.rs` with the following code. We will reuse this module in all three examples.

```rust title="src/compiler.rs"
use std::path::Path;

use typst::diag::FileResult;
use typst::foundations::{Bytes, Datetime, Dict, Duration};
use typst::syntax::{FileId, RootedPath, Source, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Library, LibraryExt, World};
use typst_kit::datetime::Time;
use typst_kit::downloader::SystemDownloader;
use typst_kit::files::{FileStore, FsRoot, SystemFiles};
use typst_kit::fonts::embedded;
use typst_kit::packages::SystemPackages;
use typst_layout::PagedDocument;

struct ReportWorld {
    library: LazyHash<Library>,
    book: LazyHash<FontBook>,
    fonts: Vec<Font>,
    files: FileStore<SystemFiles>,
    main: FileId,
    time: Time,
}

impl World for ReportWorld {
    fn library(&self) -> &LazyHash<Library> {
        &self.library
    }

    fn book(&self) -> &LazyHash<FontBook> {
        &self.book
    }

    fn main(&self) -> FileId {
        self.main
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        self.files.source(id)
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        self.files.file(id)
    }

    fn font(&self, index: usize) -> Option<Font> {
        self.fonts.get(index).cloned()
    }

    fn today(&self, offset: Option<Duration>) -> Option<Datetime> {
        self.time.today(offset)
    }
}

pub fn compile_pdf(path: &str, inputs: Dict) -> Result<Vec<u8>, String> {
    let path = Path::new(path).canonicalize().map_err(|e| e.to_string())?;
    let root = path.parent().ok_or("template needs a parent directory")?;
    let vpath = VirtualPath::virtualize(root, &path).map_err(|e| e.to_string())?;

    let fonts: Vec<Font> = embedded().map(|(font, _)| font).collect();
    let book = LazyHash::new(FontBook::from_fonts(&fonts));
    let packages = SystemPackages::new(SystemDownloader::new("typst-report"));

    let world = ReportWorld {
        library: LazyHash::new(Library::builder().with_inputs(inputs).build()),
        book,
        fonts,
        files: FileStore::new(SystemFiles::new(FsRoot::new(root.to_path_buf()), packages)),
        main: RootedPath::new(VirtualRoot::Project, vpath).intern(),
        time: Time::system(),
    };

    let result = typst::compile::<PagedDocument>(&world);
    for warning in result.warnings {
        eprintln!("Typst warning: {}", warning.message);
    }
    let document = result
        .output
        .map_err(|errors| format!("Typst compilation failed: {errors:?}"))?;

    typst_pdf::pdf(&document, &Default::default())
        .map_err(|errors| format!("PDF export failed: {errors:?}"))
}
```

This world uses the template's parent directory as the project root. Local imports and images resolve within that root, and `typst-kit` handles package imports and caches loaded files during compilation. Package imports may need network access on their first use.

The fonts are embedded in the application, so the examples work without relying on fonts installed on your computer. To load custom or system fonts, you can extend this with [`typst-kit`'s font utilities](https://docs.rs/typst-kit/0.15.1/typst_kit/fonts/).

## Usage

Create `file.typ` in the project root, next to `Cargo.toml`:

```typst title="file.typ"
= Hello from Rust

This PDF was compiled with the Typst Rust crate.
```

Then replace `src/main.rs` with:

```rust title="src/main.rs"
mod compiler;

use typst::foundations::Dict;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let pdf = compiler::compile_pdf("file.typ", Dict::new())?;
    std::fs::write("file.pdf", pdf)?;
    Ok(())
}
```

Run this from the project root:

```bash
cargo run
```

The result is `file.pdf`. Compilation happens through `typst::compile::<PagedDocument>()`, and `typst_pdf::pdf()` turns the compiled document into PDF bytes.

## Passing data from Rust to Typst

The standard library builder's `.with_inputs()` method makes a Typst dictionary available through `sys.inputs`. For structured data, we can serialize our Rust values as JSON strings and decode them in the template, as the R bindings do.

Add a JSON dependency:

```bash
cargo add serde_json@1
```

Keep `src/compiler.rs` and replace `src/main.rs` with:

```rust title="src/main.rs"
mod compiler;

use serde_json::json;
use typst::foundations::{Dict, IntoValue};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let humans = json!([
        { "name": "Joseph", "age": 25 },
        { "name": "Justine", "age": 24 },
    ]);

    let mut inputs = Dict::new();
    inputs.insert("humans".into(), humans.to_string().into_value());

    let pdf = compiler::compile_pdf("file.typ", inputs)?;
    std::fs::write("file.pdf", pdf)?;
    Ok(())
}
```

Replace `file.typ` with:

```typst title="file.typ"
#let humans = json(bytes(sys.inputs.humans))

#for human in humans [
  #human.name is #human.age years old. \
]
```

Run `cargo run` again. The PDF will contain a line for each person. The JSON encoding here is our choice: `Dict` can also hold native Typst values such as arrays and dictionaries.

## Example with Axum

We can reuse the compiler module in a small HTTP server. This example exposes `GET /report?color=%23f9f6f4` and uses the query parameter as the page background color.

Add the server dependencies:

```bash
cargo add axum@0.8
cargo add tokio@1 --features macros,rt-multi-thread,net
cargo add serde@1 --features derive
```

Replace `file.typ` with:

```typst title="file.typ"
#set page(fill: rgb(sys.inputs.color), width: 10cm, height: 5cm)

= Dynamic Typst report made with Rust
```

Here, `color` is a plain string, so the template can use it directly without JSON decoding.

Keep `src/compiler.rs` and replace `src/main.rs` with:

```rust title="src/main.rs"
mod compiler;

use axum::{
    Router,
    extract::Query,
    http::{StatusCode, header},
    response::IntoResponse,
    routing::get,
};
use serde::Deserialize;
use typst::foundations::{Dict, IntoValue};

#[derive(Deserialize)]
struct ReportParams {
    color: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let app = Router::new().route("/report", get(report));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn report(
    Query(params): Query<ReportParams>,
) -> Result<impl IntoResponse, (StatusCode, String)> {
    let pdf = tokio::task::spawn_blocking(move || {
        let mut inputs = Dict::new();
        inputs.insert("color".into(), params.color.into_value());
        compiler::compile_pdf("file.typ", inputs)
    })
    .await
    .map_err(internal_error)?
    .map_err(internal_error)?;

    Ok(([(header::CONTENT_TYPE, "application/pdf")], pdf))
}

fn internal_error(error: impl std::fmt::Display) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, error.to_string())
}
```

Typst compilation is CPU work, so `spawn_blocking` keeps it off Tokio's async worker threads. Compilation and export errors become HTTP error responses.

Start the server with `cargo run` from the project root. Then, in another terminal:

```bash
curl --fail --get --data-urlencode 'color=#f9f6f4' \
  --output report.pdf 'http://127.0.0.1:3000/report'
```

The response is saved as `report.pdf` with the requested background color.

## Other resources

- [`typst`](https://docs.rs/typst/0.15.1/typst/): the official compiler crate and its `World` interface.
- [`typst-pdf`](https://docs.rs/typst-pdf/0.15.1/typst_pdf/): PDF export and export options.
- [`typst-kit`](https://docs.rs/typst-kit/0.15.1/typst_kit/): utilities for files, packages, fonts, and dates.

<br>

!!! question

      Know of other Rust projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
