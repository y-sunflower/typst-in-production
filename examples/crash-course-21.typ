#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 4cm)
#let greet(name, vip: false) = {
  if vip {
    [Welcome back, esteemed #name!]
  } else {
    [Hello #name!]
  }
}

#greet("Joseph")

#greet("Justine", vip: true)