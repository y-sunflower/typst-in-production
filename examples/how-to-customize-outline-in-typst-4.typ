#set page(fill: rgb("#f8f9fa"), width: 15cm, height: 14cm, margin: 0.5cm)

#show outline.entry: it => {
  if it.element.body.text == "Appendix A" {
    v(0.5cm)
    rect(fill: red, height: 1pt, width: 30%)
    text(size: 12pt, fill: blue, "Appendix (work in progress)")
  }
  it
}

#outline()

= Main title
== Section

Content of the section.

== Another section
=== With a sub-section
=== And another sub-section

== Appendix A
== Appendix B

