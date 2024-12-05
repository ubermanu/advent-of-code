import assert from 'node:assert'
import fs from 'node:fs'
import path from 'node:path'

const doc = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

/** @param {string} str */
function compute(str) {
  const matches = str.matchAll(/mul\((\d+),(\d+)\)/g)
  let total = 0
  for (const m of matches) {
    total += (+m[1]) * (+m[2])
  }
  return total
}

assert.equal(compute(doc), 161)

console.log('puzzle input result:', compute(fs.readFileSync(path.resolve(import.meta.dirname, './input'), 'utf8')))
