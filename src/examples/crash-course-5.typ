#let yellow = rgb("#FFC300")
#let purple = rgb("#421173")

#set page(fill: yellow, width: 12cm, height: 5cm)

#align(horizon, stack(
  dir: ltr,
  spacing: 0.5cm,
  circle(fill: purple, width: 2cm),
  rect(fill: purple, width: 3cm, circle(fill: yellow, width: 1cm)),
))
