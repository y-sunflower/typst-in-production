#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 12cm)

#show heading: it => {
  let fill = if it.level == 1 { rgb("#264653") } else { rgb("#e9c46a") }
  let ink = if it.level == 1 { white } else { rgb("#264653") }
  let line-fill = if it.level == 1 { white } else { rgb("#264653") }
  let heading-size = if it.level == 1 { 14pt } else { 12pt }

  rect(fill: fill, radius: 8pt, inset: (x: 8pt, y: 10pt), width: 100%, [
    #underline(text(size: 9pt, fill: ink)[Section level #it.level], offset: 2pt)\
    #text(size: heading-size, weight: "bold", fill: ink)[#it.body]
  ])
}

= Kickoff plan
#lorem(15)

== Collect quotes
#lorem(15)

== Review export
#lorem(15)
