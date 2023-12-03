import fs from 'node:fs/promises'

const file = await fs.readFile("input")

function get_floor(text) {
  return Array.from(text.matchAll(/\(/g)).length - Array.from(text.matchAll(/\)/g)).length
}

console.log("The floor is:", get_floor(file.toString()))

function enters_basement_at(text) {
  let level = 0

  for (let i in text) {
    const char = text[i]
    if (char === '(') {
      level++
    }
    if (char === ')') {
      level--
    }
    if (level < 0) {
      return i + 1
    }
  }

  return 0
}

console.log("Enters basement at:", enters_basement_at(file.toString()))
