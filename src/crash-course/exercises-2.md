---
title: Exercises 2 - Scripting
---

In the following exercises, you'll need to reproduce in Typst the image you see. You can freely use the [official Typst documentation](https://typst.app/docs/)

### 1 - Combining `align` and `stack`

=== "Exercise"

    ![](../../images/crash-course-13.png)

=== "Hint"

    - Wrap your content in `align(horizon, ...)`
    - Build one vertical stack and small horizontal stacks inside it

=== "Solution"

    ```typst
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

=== "Exercise"

    ![](../../images/crash-course-14.png)

=== "Hint"

    - Define `badge(...)` with `#let`
    - Give it at least 2 parameters (`label`, `color`)
    - Add one optional parameter with a default value
    - Call the function multiple times with different arguments

=== "Solution"

    ```typst
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

### 3 - Variadic announcement bars

=== "Exercise"

    ![](../../images/crash-course-25.png)

=== "Hint"

    - Define a function with a variadic parameter like `..parts`
    - Put these parts inside a `stack(dir: ltr, ...)`
    - Mix regular text with styled text when calling the function

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 12cm, height: 5.5cm)

    #let notice(..parts) = {
      rect(
        fill: rgb("#264653"),
        radius: 6pt,
        inset: (x: 12pt, y: 8pt),
        width: 8.8cm,
        text(
          fill: white,
          stack(
            dir: ltr,
            spacing: 0.2cm,
            ..parts,
          ),
        ),
      )
    }

    #align(horizon, stack(
      spacing: 0.35cm,
      notice([Next workshop:], text(weight: "bold", "Thursday"), [10:00]),
      notice([Bring your], text(weight: "bold", "laptop"), [and charger]),
    ))
    ```

### 4 - Conditional status labels

=== "Exercise"

    ![](../../images/crash-course-26.png)

=== "Hint"

    - Define a function with one label argument and one boolean argument
    - Use `if`/`else` to change both the color and the text
    - Give the boolean argument a default value so you can omit it sometimes

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 12cm, height: 5.5cm)

    #let desk-status(label, free: true) = {
      if free {
        rect(
          fill: rgb("#2a9d8f"),
          radius: 5pt,
          inset: (x: 10pt, y: 6pt),
          text(fill: white, [#label - available]),
        )
      } else {
        rect(
          fill: rgb("#e76f51"),
          radius: 5pt,
          inset: (x: 10pt, y: 6pt),
          text(fill: white, [#label - taken]),
        )
      }
    }

    #align(horizon, stack(
      spacing: 0.3cm,
      desk-status("Desk A"),
      desk-status("Desk B", free: false),
      desk-status("Desk C"),
    ))
    ```

### 5 - Generate a checklist with a loop

=== "Exercise"

    ![](../../images/crash-course-27.png)

=== "Hint"

    - Create a function that accepts a list of task names
    - Use a `for` loop to repeat the same card layout for each item
    - Add a small `v(...)` spacer after each generated card

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 12cm, height: 6.5cm)

    #let checklist(items) = {
      for item in items {
        rect(
          fill: white,
          stroke: rgb("#adb5bd"),
          radius: 6pt,
          inset: (x: 10pt, y: 8pt),
          width: 8.6cm,
          stack(
            dir: ltr,
            spacing: 0.25cm,
            circle(fill: rgb("#4361ee"), width: 0.45cm),
            text(weight: "bold", item),
          ),
        )
        v(0.2cm)
      }
    }

    #align(horizon, checklist((
      "Write the outline",
      "Collect screenshots",
      "Export the final PDF",
    )))
    ```
