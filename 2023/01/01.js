import fs from 'fs/promises'

/** @param {string} line */
function get_first_digit(line) {
  return line.match(/\d/)[0] ?? ''
}

/** @param {string} str*/
function reverse(str) {
  return str.split('').reverse().join('')
}

function cal_sum(text) {
  const lines = text.trim().split("\n")
  let total = 0
  for (let line of lines) {
    total += +get_first_digit(line).concat(get_first_digit(reverse(line)))
  }
  console.log("Sum of calibrations values:", total)
}

const doc = `
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
`

const file = await fs.readFile("input")

cal_sum(doc)
cal_sum(file.toString())
