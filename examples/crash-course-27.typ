#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 6.5cm)

#let todo(s) = {
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
      text(weight: "bold", s),
    ),
  )
  v(0.2cm)
}

#let items = ("Write the outline", "Collect screenshots", "Export the final PDF")
#for item in items {
  todo(item)
}

