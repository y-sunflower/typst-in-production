#set page(fill: rgb("#f9f6f4"), width: 12cm, height: 5cm)

#align(horizon, stack(
  spacing: 0.2cm,
  stack(
    dir: ltr,
    spacing: 0.3cm,
    circle(fill: rgb("#2a9d8f"), width: 0.7cm),
    text(fill: rgb("#2a9d8f"), "Ready"),
  ),
  stack(
    dir: ltr,
    spacing: 0.3cm,
    circle(fill: rgb("#e9c46a"), width: 0.7cm),
    text(fill: rgb("#e9c46a"), "Pending"),
  ),
  stack(
    dir: ltr,
    spacing: 0.3cm,
    circle(fill: rgb("#e76f51"), width: 0.7cm),
    text(fill: rgb("#e76f51"), "Blocked"),
  ),
))
