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
