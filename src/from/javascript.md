---
title: Typst from JavaScript
---

!!! tip

      Make sure to check the overview of [how and why Typst can be used from JavaScript](./index.md) to fully understand it.

In JavaScript, we can use [typst.ts](https://github.com/Myriad-Dreamin/typst.ts). It lets us compile Typst directly in the browser using **WebAssembly (Wasm)**: the Rust compiler runs inside the browser, and JavaScript provides the API to use it.

This means we can build a report from data already available in our web application, show a preview, and let the user download a PDF. The document is compiled on the user's device, without sending its contents to a compilation server.

## Installation

For this example, we'll load the [browser bundle](https://myriad-dreamin.github.io/typst.ts/cookery/guide/all-in-one.html) from a CDN. There is no need to install the Typst CLI or set up a JavaScript framework.

The examples use **typst.ts 0.7.0**. Keep the JavaScript bundle, compiler Wasm, and renderer Wasm on the same version.

Create a directory with two files, `index.html` and `main.js`. To serve it locally, run this command from that directory (requires Node.js and npm):

```bash
npx --yes http-server . -c-1
```

Then open `http://localhost:8080`. Serve the files over HTTP, since the browser needs to load JavaScript modules and Wasm assets.

## Usage

First, create a page with a container for the preview:

```html title="index.html"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Typst from JavaScript</title>
  </head>
  <body>
    <p id="status">Loading Typst...</p>
    <div id="preview"></div>
    <button id="download" disabled>Download PDF</button>
    <script type="module" src="./main.js"></script>
  </body>
</html>
```

Then, configure the Wasm modules and compile a small document:

```javascript title="main.js"
import { $typst } from "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst.ts@0.7.0/dist/esm/contrib/all-in-one-lite.bundle.js";

const cdn = "https://cdn.jsdelivr.net/npm/@myriaddreamin";

$typst.setCompilerInitOptions({
  getModule: () =>
    `${cdn}/typst-ts-web-compiler@0.7.0/pkg/typst_ts_web_compiler_bg.wasm`,
});

$typst.setRendererInitOptions({
  getModule: () =>
    `${cdn}/typst-ts-renderer@0.7.0/pkg/typst_ts_renderer_bg.wasm`,
});

const mainContent = `
#set page(width: 12cm, height: 6cm, margin: 1cm)

= Hello from JavaScript

This document was compiled in the browser.
`;

const options = { mainContent };
const status = document.getElementById("status");
const download = document.getElementById("download");

try {
  const svg = await $typst.svg(options);
  document.getElementById("preview").innerHTML = svg;
  status.textContent = "Your document is ready.";
  download.disabled = false;
} catch (error) {
  status.textContent = "Could not compile the document.";
  console.error(error);
}
```

`mainContent` is a string containing Typst source. `$typst.svg()` compiles it and returns SVG markup that we can insert into the page.

The compiler and renderer have different roles: the compiler typesets the document, and the renderer displays the compiled result. The [getting started guide](https://myriad-dreamin.github.io/typst.ts/cookery/get-started.html) explains why they are distributed as separate Wasm modules. The simplified `$typst` API connects them for us.

!!! info

      The first compilation needs to download the Wasm modules and font assets. This example requires an internet connection, even though compilation itself happens locally in the browser.

## Downloading a PDF

To make the download button work, append this to `main.js`:

```javascript title="main.js"
download.addEventListener("click", async () => {
  download.disabled = true;
  status.textContent = "Creating PDF...";

  try {
    const pdf = await $typst.pdf(options);
    if (!pdf) {
      throw new Error("PDF compilation failed");
    }

    const blob = new Blob([pdf], { type: "application/pdf" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "report.pdf";
    document.body.append(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 60_000);
    status.textContent = "Your PDF is ready.";
  } catch (error) {
    status.textContent = "Could not create the PDF.";
    console.error(error);
  } finally {
    download.disabled = false;
  }
});
```

`$typst.pdf()` returns PDF bytes, which we put in a browser `Blob` and download as `report.pdf`. This exports a PDF directly from Typst, so we don't need to print the SVG preview through the browser.

## Passing data from JavaScript to Typst

As with the [Python bindings](./python.md), we can pass data through [`sys.inputs`](https://typst.app/docs/reference/foundations/sys/). The values are strings, so we use `JSON.stringify()` for arrays and objects.

In `main.js`, replace the definitions of `mainContent` and `options` with:

```javascript title="main.js"
const humans = [
  { name: "Joseph", age: 25 },
  { name: "Justine", age: 24 },
];

const mainContent = String.raw`
#set page(width: 12cm, height: 6cm, margin: 1cm)
#let humans = json(bytes(sys.inputs.humans))

= Our team

#for human in humans [
  #human.name is #human.age years old. \
]
`;

const options = {
  mainContent,
  inputs: { humans: JSON.stringify(humans) },
};
```

On the Typst side, [`json(bytes(...))`](https://typst.app/docs/reference/data-loading/json/) decodes the input into an array of dictionaries. `String.raw` preserves the backslash used for the Typst line break.

Reload the page: both the preview and the downloaded PDF now contain a line for each person. We can use the same approach with data from a form, an API response, or calculations in our application. Passing values as inputs also keeps that data separate from the Typst source.

## Using it in an application

The CDN example is enough to get started. For an application with a bundler, we can install the components through npm:

```bash
npm install @myriaddreamin/typst.ts@0.7.0 \
  @myriaddreamin/typst-ts-web-compiler@0.7.0 \
  @myriaddreamin/typst-ts-renderer@0.7.0
```

Then import `$typst` from `@myriaddreamin/typst.ts`. We still need to configure `getModule` with URLs that our application serves for the Wasm files, or keep the CDN URLs above. Do this before the first compilation.

A few things to keep in mind when moving beyond this example:

- **Fonts and files:** the browser cannot read arbitrary files or fonts from the user's computer. Supply custom fonts and project assets explicitly. The [browser API documentation](https://myriad-dreamin.github.io/typst.ts/cookery/guide/all-in-one.html) covers font loading, `addSource()` for source files, and `mapShadow()` for binary assets such as images.
- **Loading:** keep the compiler instance around for subsequent reports, and show a loading state while the first download and compilation finish. For offline use, host and cache the Wasm modules, fonts, and any packages the document imports.
- **Editing:** compilation takes CPU time. For a live editor, debounce changes and consider moving compilation to a Web Worker to keep the page responsive. Avoid overlapping calls on the shared `$typst` instance.

Being able to compile in the browser is useful for interactive reports: JavaScript handles the application logic, and Typst handles the document layout and PDF output.

## Other resources

- [typst.ts documentation](https://myriad-dreamin.github.io/typst.ts/): compiler, renderer, and framework integration guides.
- [Single-file previewer](https://github.com/Myriad-Dreamin/typst.ts/blob/main/github-pages/preview.html): a complete browser example to explore beyond this tutorial.
- [`@myriaddreamin/typst.react`](https://www.npmjs.com/package/@myriaddreamin/typst.react): React components for displaying compiled Typst artifacts. Rendering an artifact and compiling Typst source are separate steps.
- [Node.js compiler](https://myriad-dreamin.github.io/typst.ts/cookery/guide/all-in-one-node.html): a native binding from the same project for compiling on a Node.js server.

<br>

!!! question

      Know of other projects that would be a good fit here? Feel free to [open an issue](https://github.com/y-sunflower/typst-in-production/issues).
