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
