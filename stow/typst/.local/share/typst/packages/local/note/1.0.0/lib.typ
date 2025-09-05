#import "@preview/ctheorems:1.1.3": *
#import "@preview/diverential:0.2.0": *

#let style(body) = {
  set text(
     font: "New Computer Modern",
     size: 16pt,
   )

  set page(height: auto, margin: 1.5cm)
  set heading(numbering: "1.1")
  set enum(numbering: "1)")
  show heading: set block(above: 1.5em, below: 1em)
  show: thmrules

  body
}

#let definition = thmbox(
  "definition",
  "Определение",
  outset: 0.3em,
  inset: 0.8em,
  stroke: 0.2pt,
  fill: rgb("#deffba86"),
).with(numbering: none)

#let theorem = thmbox(
  "theorem",
  "Теорема",
  outset: 0.3em,
  inset: 0.8em,
  stroke: 0.2pt,
  fill: rgb("#fff9c086"),
).with(numbering: none)

#let lemma = thmbox(
  "lemma",
  "Лемма",
  outset: 0.3em,
  inset: 0.8em,
  stroke: 0.2pt,
  fill: rgb("#fff9c086"),
).with(numbering: none)

#let corollary = thmbox(
  "corollary",
  "Следствие",
  outset: 0.3em,
  inset: 0.8em,
  stroke: 0.2pt,
  fill: rgb("#fff9c086"),
).with(numbering: none)

#let example = thmplain(
  "example",
  "Пример",
  outset: 0em,
  inset: 0em,
).with(numbering: none)

#let note = thmplain(
  "note",
  "Замечание",
  outset: 0em,
  inset: 0em,
).with(numbering: none)

#let proof = thmproof(
  "proof",
  "Доказательство",
  outset: 0em,
  inset: 0em,
)

