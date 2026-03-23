#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 4cm)
#let custom-stack(..args) = {
  box(fill: red, inset: 5pt, stack(
    dir: ttb,
    spacing: 10pt,
    ..args.pos().map(val => box(stroke: 0.5pt + black, val)),
  ))
}

#custom-stack("hey", "you")
#custom-stack("we can add a", circle(fill: blue), "circle")