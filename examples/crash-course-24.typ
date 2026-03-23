#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 4cm)

#let custom-component(lab, col)= {
  align(
    horizon,
    stack(dir: ltr, spacing: 0.3cm, circle(fill: col, width: 0.7cm), text(fill: col, lab)),
  )
}

#custom-component("Ready", rgb("#2a9d8f"))
#custom-component("Pending", rgb("#e9c46a"))
#custom-component("Blocked", rgb("#e76f51"))
