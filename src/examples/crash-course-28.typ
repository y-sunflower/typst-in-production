#set page(fill: rgb("#f8f9fa"), width: 12cm, height: 9cm, margin: 0.5cm)

#let banner(label, alert: false) = {
  if alert {
    rect(
      fill: rgb("#e76f51"),
      radius: 999pt,
      inset: (x: 12pt, y: 6pt),
      text(weight: "bold", fill: white, label),
    )
  } else {
    rect(
      fill: rgb("#264653"),
      radius: 999pt,
      inset: (x: 12pt, y: 6pt),
      text(weight: "bold", fill: white, label),
    )
  }
}

#let note-list(..notes) = {
  for note in notes.pos() {
    [- #note \ ]
  }
}

#let task-card(title, color, ..notes) = {
  rect(
    fill: white,
    stroke: color,
    radius: 8pt,
    inset: 12pt,
    width: 9cm,
    [
      #text(weight: "bold", fill: color, title)
      #v(0.15cm)
      #note-list(..notes)
    ],
  )
}

#align(horizon, stack(
  spacing: 0.35cm,
  banner("Release board"),
  task-card("Homepage", rgb("#2a9d8f"), "Hero ready", "CTA checked"),
  task-card("Slides", rgb("#e9c46a"), "Add one chart", "Shorten intro"),
  banner("1 item needs review", alert: true),
))
