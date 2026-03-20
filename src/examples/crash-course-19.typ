#set page(fill: rgb("#f8f9fa"), width: 12cm, height: 4cm)
#let custom-box(label, fill: red) = {
  box(fill: fill, width: 4cm, inset: 5pt, text(weight: "bold", label))
}

#custom-box("Life is good")
#custom-box("Life is good", fill: green)