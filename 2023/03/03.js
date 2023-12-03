import fs from 'fs/promises'

const doc = `
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
`

const file = await fs.readFile('input')

/** @param {string} line */
function get_numbers(line) {
	return Array.from(line.matchAll(/(\d+)/g))
}

/** @param {string} line */
function get_symbols(line) {
	return Array.from(line.matchAll(/([^\d\.\s])/g))
}

/** @param {string} line */
/** @param {string} prev */
/** @param {string} next */
function get_part_numbers(line, prev, next) {
	/** @var {number[]} parts */
	const parts = []

	const numbers = get_numbers(line)

	if (numbers.length === 0) {
		return []
	}

	const checks = [
		get_symbols(line),
		prev ? get_symbols(prev) : null,
		next ? get_symbols(next) : null
	].filter(Boolean)

	for (let number of numbers) {
		checks.forEach(symbols => {
			for (let symbol of symbols) {
				if (symbol.index >= number.index - 1 && symbol.index <= number.index + number[0].length) {
					parts.push(+number[0])
				}
			}
		})
	}

	return parts
}

function sum_parts(text) {
	let parts = []
	const lines = text.trim().split('\n')

	for (let i = 0, l = lines.length; i < l; i++) {
		parts = parts.concat(get_part_numbers(lines[i], lines[i - 1], lines[i + 1]))
	}

	console.log(parts)

	return parts.reduce((value, cur) => value + cur, 0)
}

console.log("Sum of the part numbers:", sum_parts(doc))
console.log("Sum of the part numbers:", sum_parts(file.toString()))
