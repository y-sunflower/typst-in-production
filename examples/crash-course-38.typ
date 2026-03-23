#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 8cm, margin: 0.6cm)

#show heading: it => {
  let fill = if it.level == 1 { rgb("#264653") } else { rgb("#e9c46a") }
  let ink = if it.level == 1 { white } else { rgb("#264653") }

  block(
    width: 100%,
    below: 0.15cm,
    rect(
      fill: fill,
      radius: 8pt,
      inset: (x: 12pt, y: 9pt),
      width: 100%,
      [
        #text(size: 9pt, fill: ink)[Section level #it.level]
        \
        #text(weight: "bold", fill: ink)[#it.body]
      ],
    ),
  )
}

= Kickoff plan
The first checklist is ready.

== Collect quotes
We still need two final numbers.

== Review export
The PDF draft should be checked today.
