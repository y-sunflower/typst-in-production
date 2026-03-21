#set page(fill: rgb("#f8f9fa"), width: 12cm, height: 4cm)

#align(horizon, stack(
  dir: ltr,
  spacing: 0.3cm,
  circle(fill: rgb("#2a9d8f"), width: 0.7cm),
  text(fill: rgb("#2a9d8f"), "Ready"),
))

#align(horizon, stack(
  dir: ltr,
  spacing: 0.3cm,
  circle(fill: rgb("#e9c46a"), width: 0.7cm),
  text(fill: rgb("#e9c46a"), "Pending"),
))

#align(horizon, stack(
  dir: ltr,
  spacing: 0.3cm,
  circle(fill: rgb("#e76f51"), width: 0.7cm),
  text(fill: rgb("#e76f51"), "Blocked"),
))