#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 11cm, margin: 0.5cm)

#show outline.entry.where(level: 2): it => {
  v(0.3cm)
  rect(fill: red, height: 1pt, width: 100%)
  it
}

#outline()

= Main title
== Section

Content of the section.

== Another section
=== With a sub-section
=== And another sub-section

