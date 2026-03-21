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
