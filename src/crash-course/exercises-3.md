---
title: Exercises 3 - Templating
---

In the following exercises, you'll need to reproduce in Typst the image you see. You can freely use the [official Typst documentation](https://typst.app/docs/).

!!! info

    In the following exercises, **there isn't just one way of doing things**! The best way is often the simplest: it minimizes code duplication and makes code reusable and easy to maintain.

### 1 - Build a small release board

=== "Exercise"

    ![Small release board with a dark title pill, two outlined task cards, and a red review banner](../../images/crash-course-28.png)

=== "Hint"

    - Split the work into small reusable functions instead of writing one large block
    - Use another function with `..notes`, then loop over these notes to build each card

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 15cm, height: 10cm, margin: 0.5cm)

    #let banner(label, fill) = {
      rect(
        fill: fill,
        radius: 999pt,
        inset: (x: 12pt, y: 6pt),
        text(weight: "bold", fill: white, label),
      )
    }

    #let note-list(..notes) = {
      for note in notes.pos() {
        [- #note \ ]
      }
    }

    #let task-card(title, color, ..notes) = {
      rect(fill: white, stroke: color, radius: 8pt, inset: 12pt, width: 9cm, [
        #text(weight: "bold", fill: color, title)
        #v(0.15cm)
        #note-list(..notes)
      ])
    }

    #banner("Release board", rgb("#264653"))
    #task-card(
      "Homepage",
      rgb("#2a9d8f"),
      "Hero ready",
      "CTA checked",
      "Add final screenshot",
    )
    #task-card("Slides", rgb("#e9c46a"), "Add one chart", "Shorten intro")
    #banner("1 item needs review", rgb("#e76f51"))
    ```

### 2 - Color headings with `show`

=== "Exercise"

    ![](../../images/crash-course-37.png)

=== "Hint"

    - Use `#show heading.where(level: 1): ...`
    - Then add another show rule for `level: 2`
    - Inside each show rule, apply a `set text(...)`

=== "Solution"

    ```typst
    #show heading.where(level: 1): set text(fill: rgb("#2a9d8f"))
    #show heading.where(level: 2): set text(fill: rgb("#4361ee"))

    = Workshop notes (level 1)
    == Materials (level 2)
    This section introduces the session.

    == What to bring (level 2)
    Bring your laptop and a charger.
    ```

### 3 - Turn headings into section cards

=== "Exercise"

    ![Document with a dark section card for Kickoff plan, two amber subheading cards, and short paragraphs under each one](../../images/crash-course-38.png)

=== "Hint"

    - Write a `#show heading: it => ...` rule
    - Use `it.body` and `it.level`
    - Use an `if`/`else` to change the card colors depending on the heading level
    - Wrap each transformed heading in a full-width rounded `rect(...)`

=== "Solution"

    ```typst
    #set page(fill: rgb("#f8f9fa"), width: 15cm, height: 8cm, margin: 0.6cm)

    #show heading: it => {
      let fill = if it.level == 1 { rgb("#264653") } else { rgb("#e9c46a") }
      let ink = if it.level == 1 { white } else { rgb("#264653") }

      block(
        width: 100%,
        below: 0.15cm,
        rect(
          fill: fill,
          radius: 8pt,
          inset: (x: 12pt, y: 9pt),
          width: 100%,
          [
            #text(size: 9pt, fill: ink)[Section level #it.level]
            \
            #text(weight: "bold", fill: ink)[#it.body]
          ],
        ),
      )
    }

    = Kickoff plan
    The first checklist is ready.

    == Collect quotes
    We still need two final numbers.

    == Review export
    The PDF draft should be checked today.
    ```

### 4 - Design a report header and footer

=== "Exercise"

    ![Single-page report with a dark rounded header labeled Project Atlas, a green page-number badge, short body text, and a small footer note](../../images/crash-course-39.png)

=== "Hint"

    - Use `#set page(header: ..., footer: ...)`
    - Put the page-number badge inside `#context[...]`
    - Use `here().page()` for the current page and `counter(page).final().at(0)` for the total
    - Build the badge with a rounded `rect(...)`

=== "Solution"

    ```typst
    #set page(
      fill: rgb("#f8f9fa"),
      width: 15cm,
      height: 6cm,
      margin: (top: 1.4cm, bottom: 1cm, x: 0.7cm),
      header: {
        rect(
          fill: rgb("#264653"),
          radius: 8pt,
          inset: (x: 12pt, y: 8pt),
          width: 100%,
          [
            #text(fill: white, weight: "bold")[Project Atlas]
            #align(right)[
              #context [
                #rect(
                  fill: rgb("#2a9d8f"),
                  radius: 999pt,
                  inset: (x: 10pt, y: 4pt),
                  text(fill: white)[Page #here().page() / #counter(page).final().at(0)],
                )
              ]
            ]
          ],
        )
      },
      footer: {
        align(right)[
          #text(fill: rgb("#6c757d"), size: 9pt)[Internal draft]
        ]
      },
    )

    = Sprint update
    The launch checklist is almost complete.

    One last review remains before export.
    ```

<br>
<br>

!!! Question

    Having questions? Feedback? [Feel free to ask](https://github.com/y-sunflower/typst-in-production/issues)!
