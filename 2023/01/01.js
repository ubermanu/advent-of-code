import fs from 'fs/promises'

const digits = {
  0: 'zero',
  1: 'one',
  2: 'two',
  3: 'three',
  4: 'four',
  5: 'five',
  6: 'six',
  7: 'seven',
  8: 'eight',
  9: 'nine'
}

/** @param {string} line */
/** @param {boolean} rev */
function get_first_digit(line, rev = false) {
  let idx = -1
  let digit = ''

  if (rev) {
    line = reverse(line)
  }

  const match = /\d/.exec(line)
  if (match) {
    idx = match.index
    digit = match[0]
  }

  for (let d of Object.entries(digits)) {
    const i = line.indexOf(rev ? reverse(d[1]) : d[1])
    if (i > -1 && (i < idx || idx === -1)) {
      idx = i
      digit = d[0]
    }
  }

  return digit
}

/** @param {string} str*/
function reverse(str) {
  return str.split('').reverse().join('')
}

function cal_sum(text) {
  const lines = text.trim().split("\n")
  let total = 0
  for (let line of lines) {
    total += +get_first_digit(line).concat(get_first_digit(line, true))
  }
  console.log("Sum of calibrations values:", total)
}

const doc = `
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
`

const doc2 = `
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
`

const file = await fs.readFile("input")

cal_sum(doc)
cal_sum(doc2)
cal_sum(file.toString())
