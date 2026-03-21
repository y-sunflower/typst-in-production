---
title: Lesson 2 - Scripting
---

## Create your own functions

Even though Typst is a markup language (!= a programming language), it embeds a scripting language that lets us add **logic** (`if`/`else` statements, `for` loops, etc.) and create reusable components/functions.

Let's look at an example:

```typst
#set page(fill: aqua)

#let say-hello(s) = {
  [Hello, my friend #s, how are you?]
}

#say-hello("Joseph")

#say-hello("Justine")
```

![](../../images/crash-course-6.png)

Once again we use the `let` keyword, and then we wrap the output of the function inside curly braces.

## Functions with default arguments

Functions can have as many arguments as we want and let some of them have default values:

```typst
#let custom-box(label, fill: red) = {
   box(fill: fill, width: 4cm, inset: 5pt, text(weight: "bold", label))
}

#custom-box("Life is good")
#custom-box("Life is good", fill: green)
```

![](../../images/crash-course-19.png)

## Variadic arguments

You can make your function accept any number of arguments by using variadic arguments:

```typst
#let custom-stack(..args) = {
  box(fill: red, inset: 5pt, stack(
      dir: ttb,
      spacing: 10pt,
      ..args
   ))
}

#custom-stack("hey", "you")
#custom-stack("we can add a", circle(fill: blue), "circle")
```

![](../../images/crash-course-20.png)

## `if`/`else`

You can use the `if`/`else` statements, which, for example, can be useful to create flexible functions:

```typst
#let greet(name, vip: false) = {
  if vip {
    [Welcome back, esteemed #name!]
  } else {
    [Hello #name!]
  }
}

#greet("Joseph")

#greet("Justine", vip: true)
```

![](../../images/crash-course-21.png)

## `for` loops

You can use `for` loops to repeat content or iterate over a list:

```typst
#let name-list(names) = {
  for name in names {
    [• Hello #name \ ]
  }
}

#name-list(("Joseph", "Justine", "Alex", "Victoria"))
```

![](../../images/crash-course-22.png)

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

- highly reusable: we can call the `custom-component` function many other times
- easier to maintain: change the function definition to update all of its uses

Typst is really well-designed for this component mindset, and it's a good idea to use it from the beginning.
