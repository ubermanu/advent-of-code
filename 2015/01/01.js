import fs from 'node:fs/promises'

const file = await fs.readFile("input")

function get_floor(text) {
  return Array.from(text.matchAll(/\(/g)).length - Array.from(text.matchAll(/\)/g)).length
}

console.log("The floor is:", get_floor(file.toString()))
