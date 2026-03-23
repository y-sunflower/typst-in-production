#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 4cm)
#let name-list(names) = {
  for name in names {
    [• Hello #name \ ]
  }
}

#name-list(("Joseph", "Justine", "Alex", "Victoria"))