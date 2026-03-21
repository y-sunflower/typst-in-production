#set page(fill: rgb("#f8f9fa"), width: 12cm, height: 4cm)
#let custom-stack(..args) = {
  box(fill: red, inset: 5pt, stack(dir: ttb, spacing: 10pt, ..args))
}

#custom-stack("hey", "you")
#custom-stack("we can add a", circle(fill: blue), "circle")