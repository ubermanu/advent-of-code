import fs from "node:fs/promises"

let doc = `
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
`

doc = (await fs.readFile("input")).toString()

let image = []

doc.trim().split("\n").forEach((line) => {
  image.push(line.split(""))
})

console.log("Image:")
console.log(image.map(r => r.join("")).join("\n"))

// Expand rows
for (let i = image.length - 1; i >= 0; i--) {
  if (image[i].indexOf('#') < 0) {
    image.splice(i, 0, image[i])
  }
}

// Expand columns
let cols = image
  .map(row => parseInt(row.join("").replace(/\./g, 0).replace(/#/g, 1), 2))
  .reduce((prev, cur) => prev | cur, 0)
  .toString(2)
  .split("")

image.forEach((row) => {
  for (let j = cols.length - 1; j >= 0; j--) {
    if (cols[j] === "0") {
      row.splice(j, 0, ".")
    }
  }
})

console.log("Expanded:")
console.log(image.map(r => r.join("")).join("\n"))

let galaxies = []
let id = 0

image.forEach((row, y) => {
  row.forEach((char, x) => {
    if (char === "#") {
      galaxies.push({ id: ++id, x, y })
    }
  })
})

let total = 0

while (galaxies.length > 0) {
  const [g, ...rest] = galaxies

  rest.forEach((gn) => {
    const distance = Math.abs(g.x - gn.x) + Math.abs(g.y - gn.y)
    console.log(JSON.stringify(g), JSON.stringify(gn), ' => ', distance)
    total += distance
  })

  galaxies = rest
}

console.log("Sum of the length is:", total)
