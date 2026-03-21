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
