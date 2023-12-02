import fs from 'fs/promises'

const doc = `
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
`

const file = await fs.readFile('input')

function parse_game_data(line) {
	let id, sets

	id = +line.match(/^Game (\d+):/)[1]

	sets = line.match(/^Game \d+:\s(.*)/)[1].split(';')

	sets = sets.map(set => {
		const balls = set.split(',')

		set = {}

		for (let ball of balls) {
			ball = ball.trim()
			const n = ball.split(' ')[0]
			const key = ball.split(' ')[1].toLowerCase()
			set[key] = +n
		}

		return set
	})

	return { id, sets }
}


function parse_games(text) {
	const lines = text.trim().split("\n")
	const games = []

	for (let line of lines) {
		games.push(parse_game_data(line))
	}

	return games
}


function game_satisfies(game, criteria) {

	for (let set of game.sets) {
		const counter = {}

		for (let k in set) {
			if (counter[k]) {
				counter[k] += set[k]
			} else {
				counter[k] = set[k]
			}
		}

		for (let k in criteria) {
			if (!counter[k]) {
				continue
			}
			if (counter[k] > criteria[k]) {
				return false
			}
		}
	}

	return true
}


function possible_id_sum(text, criteria) {
	let total = 0

	for (let game of parse_games(text)) {
		if (game_satisfies(game, criteria)) {
			total += game.id
		}
	}

	return total
}

const criteria1 = { red: 12, green: 13, blue: 14 }
console.log('Sum of the possible IDs:', possible_id_sum(doc, criteria1))
console.log('Sum of the possible IDs:', possible_id_sum(file.toString(), criteria1))


function minimum_criteria(game) {
	const criteria = {}

	for (let set of game.sets) {
		for (let k in set) {
			if (!criteria[k] || criteria[k] < set[k]) {
				criteria[k] = set[k]
			}
		}
	}

	return criteria
}


function power_sets_sum(text) {
	let total = 0

	for (let game of parse_games(text)) {
		const min = minimum_criteria(game)
		const power = min?.green * min?.red * min?.blue
		total += power
	}

	return total
}

console.log('Sum of power of sets:', power_sets_sum(doc))
console.log('Sum of power of sets:', power_sets_sum(file.toString()))
