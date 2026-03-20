---
title: Exercises
---

## Exercises

!!! note

    - Make sure to either [install Typst](https://typst.app/open-source/) or use their [web app](https://typst.app/play/)
    - Always include `#set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)` at the top of the document to:
        - ensure a fixed page size, because by default it will be A4, which is more than necessary
        - have a distinct background (light grey)

### 1 - Basics

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-9.png)

=== "Hint"

    - Headings are made using the `=` symbol
    - Paragraphs can be written directly, like in Markdown

=== "Solution"

    ```typst
    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

    == My first Typst document

    My name is Joseph, and I love cookies
    ```

### 2 - A first shape

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-10.png)

=== "Hint"

    - Call the `circle()` function with a `#`
    - Use `fill` and `width` arguments

=== "Solution"

    ```typst
    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

    #circle(fill: rgb("#3a86ff"), width: 2.5cm)
    ```

### 3 - Layout with `stack`

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-11.png)

=== "Hint"

    - Use `stack()` with `dir: ltr`
    - Add `spacing` between elements
    - Put a `circle()`, a `rect()`, and a `text()` inside
    - Look at the `radius` argument in `stack()` and the `size` argument in `text()`

=== "Solution"

    ```typst
    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

    #stack(
      dir: ltr,
      spacing: 0.5cm,
      circle(fill: rgb("#4361ee"), width: 1.2cm),
      rect(fill: rgb("#4cc9f0"), width: 2.4cm, height: 1.2cm, radius: 4pt),
      text(fill: rgb("#3a0ca3"), size: 16pt, "Typst"),
    )
    ```

### 4 - Variables and set rules

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-12.png)

=== "Hint"

    - Define the main color (#e76f51) with `#let`
    - Use `#set text(...)` to style all text at once

=== "Solution"

    ```typst
    #let main-color = rgb("#e76f51")

    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)
    #set text(fill: main-color)

    == Weekly report

    Everything uses the same text color.

    #rect(fill: main-color, width: 4.5cm, height: 0.5cm, radius: 3pt)
    ```

### 5 - Combining `align` and `stack`

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-13.png)

=== "Hint"

    - Wrap your content in `align(horizon, ...)`
    - Build one vertical stack and small horizontal stacks inside it
    - Reuse the same pattern for 3 status lines

=== "Solution"

    ```typst
    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

    #align(horizon, stack(
      spacing: 0.2cm,
      stack(
        dir: ltr,
        spacing: 0.3cm,
        circle(fill: rgb("#2a9d8f"), width: 0.7cm),
        text(fill: rgb("#2a9d8f"), "Ready"),
      ),
      stack(
        dir: ltr,
        spacing: 0.3cm,
        circle(fill: rgb("#e9c46a"), width: 0.7cm),
        text(fill: rgb("#e9c46a"), "Pending"),
      ),
      stack(
        dir: ltr,
        spacing: 0.3cm,
        circle(fill: rgb("#e76f51"), width: 0.7cm),
        text(fill: rgb("#e76f51"), "Blocked"),
      ),
    ))
    ```

### 6 - Create a function with parameters

Reproduce the PDF below:

=== "Exercise"

    ![](../examples/crash-course-14.png)

=== "Hint"

    - Define `badge(...)` with `#let`
    - Give it at least 2 parameters (`label`, `color`)
    - Add one optional parameter with a default value
    - Call the function multiple times with different arguments

=== "Solution"

    ```typst
    #set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

    #let badge(label, color, icon: "*") = {
      rect(
        fill: color,
        radius: 5pt,
        inset: (x: 10pt, y: 6pt),
        text(fill: white, [#icon #label]),
      )
    }

    #stack(
      dir: ltr,
      spacing: 0.35cm,
      badge("Draft", rgb("#6c757d")),
      badge("Review", rgb("#f77f00"), icon: "!"),
      badge("Done", rgb("#2a9d8f"), icon: "+"),
    )
    ```

<br><br>

## Next step

You now have some good Typst foundations! If you want to learn more, you can have a look at this _unofficial_ [Typst Examples Book](https://sitandr.github.io/typst-examples-book/book/about.html).

Otherwise you're ready to start using [Typst from a programming language](/from/index.md)!
