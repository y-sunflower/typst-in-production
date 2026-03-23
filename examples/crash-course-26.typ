#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 5.5cm)

#let desk-status(label, free: true) = {
  let s = if free { [#label - available] } else { [#label - taken] }
  let c = if free { rgb("#2a9d8f") } else { rgb("#e76f51") }
  rect(fill: c, radius: 5pt, inset: (x: 10pt, y: 6pt), text(fill: white, s))
}

#align(horizon, stack(
  spacing: 0.3cm,
  desk-status("Desk A"),
  desk-status("Desk B", free: false),
  desk-status("Desk C"),
))
