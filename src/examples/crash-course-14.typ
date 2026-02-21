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
