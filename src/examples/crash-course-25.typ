#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 5.5cm)
#set text(fill: white, size: 9pt)

#let notice(..parts) = {
  rect(fill: rgb("#264653"), radius: 6pt, inset: (x: 12pt, y: 8pt), stack(
    dir: ttb,
    spacing: 0.2cm,
    text(weight: "bold", size: 11pt)[Important info:],
    ..parts,
  ))
}

#align(horizon, stack(
  dir: ltr,
  spacing: 0.35cm,
  notice("$10 to enter", "Children welcomed"),
  notice("Free drinks", "Starts at 8:00", "Children allowed"),
  notice(rect(fill: red, radius: 30%, "Event canceled")),
))
