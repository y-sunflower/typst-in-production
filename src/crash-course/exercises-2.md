---
title: Exercises 2 - Scripting
---

### 1 - Combining `align` and `stack`

Reproduce the PDF below:

=== "Exercise"

    ![](../../images/crash-course-13.png)

=== "Hint"

    - Wrap your content in `align(horizon, ...)`
    - Build one vertical stack and small horizontal stacks inside it
    - Reuse the same pattern for 3 status lines

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 12cm, height: 5cm)

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

### 2 - Create a function with parameters

Reproduce the PDF below:

=== "Exercise"

    ![](../../images/crash-course-14.png)

=== "Hint"

    - Define `badge(...)` with `#let`
    - Give it at least 2 parameters (`label`, `color`)
    - Add one optional parameter with a default value
    - Call the function multiple times with different arguments

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 12cm, height: 5cm)

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
