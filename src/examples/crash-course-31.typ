#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 3cm)

#show heading: it => align(right)[
  #text(weight: "bold", [_The heading is_: "#it.body" (level: #it.level)])
]

= Hey you
== Section
And the rest of the document