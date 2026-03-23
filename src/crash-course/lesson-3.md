---
title: Lesson 3 - Templating
---

## Components

Components **aren't** a Typst concept, but they're probably a good way to think about functions and, more generally, about development. For example, let's look at this code:

```typst
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
```

![](../../images/crash-course-23.png)

The code is highly duplicated! Only the label and the color are changing in each element. Instead, what we want to do is:

```typst
#let custom-component(lab, col) = {
  align(horizon, stack(
      dir: ltr,
      spacing: 0.3cm,
      circle(fill: col, width: 0.7cm),
      text(fill: col, lab)
   ))
}

#custom-component("Ready", rgb("#2a9d8f"))
#custom-component("Pending", rgb("#e9c46a"))
#custom-component("Blocked", rgb("#e76f51"))
```

![](../../images/crash-course-24.png)

This makes our code:

- **highly reusable**: we can call the `custom-component` function many other times
- **easier to maintain**: change the function definition to update all of its uses

Typst is really well-designed for this component mindset, and it's a good idea to use it from the beginning.

## set and show rules

Our previous example could also be made using set (that we already saw in the first lesson) rules. As a reminder, a set rules defines the default behavior of a function. For example, if I write:

```typst
#set circle(width: 1cm)
```

Then by default all circle will have a width of 1cm. If we take our example from before:

```typst
#set stack(dir: ltr, spacing: 0.3cm)
#set circle(width: 0.7cm)

#align(horizon, stack(
  circle(fill: rgb("#2a9d8f")),
  text(fill: rgb("#2a9d8f"), "Ready"),
))

#align(horizon, stack(
  circle(fill: rgb("#e9c46a")),
  text(fill: rgb("#e9c46a"), "Pending"),
))

#align(horizon, stack(
  circle(fill: rgb("#e76f51")),
  text(fill: rgb("#e76f51"), "Blocked"),
))
```

![](../../images/crash-course-24.png)

Typst also has a more advanced version of set rules that is called **show rules**. Basically show rules let us define what happens when a function is called. Let's see an example:

```typst
#show heading: set text(fill: blue)

== Hey you
Content of the document

== Another section
And the rest of the document
```

![](../../images/crash-course-29.png)

Here our show rules say: when adding an heading, set the text to blue by default. Very practical! But what if we want to apply a different color depending on the heading level?

```typst
#show heading.where(level: 1): set text(fill: green)
#show heading.where(level: 2): set text(fill: blue)

= Hey you
== Section
And the rest of the document
```

![](../../images/crash-course-30.png)

But we can even fo much further with show rules! For example:

```typst
#show heading: it => align(right)[
  #text(weight: "bold", [_The heading is_: "#it.body" (level: #it.level)])
]

= Hey you
== Section
And the rest of the document
```

![](../../images/crash-course-31.png)

In short: we can do whatever we want! Here `it` represents our heading:

- `it.body`: the content
- `it.level`: the heading level
- `it.*`: this works for [all other arguments](https://typst.app/docs/reference/model/heading/) in the heading function (and for all functions too)!

Show rules differ from set rules by the fact that they don't just control default arguments of a function, but **how that function will behave** when called, which is an extremely powerful mechanism.

## Header and footer

One thing where Typst shines is by minimizing code dupplication: it's very rare that you **need** to write twice the same code and it's often a symptom that your code should be refactored.
