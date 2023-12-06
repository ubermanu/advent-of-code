import fs from 'node:fs/promises'

const doc = `
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
`

type Instruction = {
  type: 'SET' | 'AND' | 'OR' | 'NOT' | 'RSHIFT' | 'LSHIFT'
  args: string[]
  to: string
}

function parse_instructions(text: string): Instruction[] {
  const stack: Instruction[] = []
  const lines = text.trim().split("\n")

  for (let line of lines) {
    const [, cmd, to] = line.match(/(.*)\s->\s(\w)/) ?? []

    const inst: Instruction = {
      type: 'SET',
      args: [],
      to
    }

    if (/^\w+$/.test(cmd)) {
      inst.args = [cmd]
    } else {
      const [, arg1, op, arg2] = cmd.match(/^([a-z0-9]+)?\s?([A-Z]+)\s?([a-z0-9]+)$/) ?? []
      inst.type = op as Instruction['type']
      inst.args = [arg1, arg2].filter(Boolean)
    }

    stack.push(inst)
  }

  return stack
}

type WireGrid = Record<string, number>

function exec_instructions(instructions: Instruction[]): WireGrid {
  const grid: WireGrid = {}

  for (let inst of instructions) {
    switch (inst.type) {
      case 'SET':
        grid[inst.to] = /^\d+$/.test(inst.args[0]) ? +inst.args[0] : grid[inst.args[0]]
        break
      case 'AND':
        grid[inst.to] = grid[inst.args[0]] & grid[inst.args[1]]
        break
      case 'OR':
        grid[inst.to] = grid[inst.args[0]] | grid[inst.args[1]]
        break
      case 'NOT':
        grid[inst.to] = ~grid[inst.args[0]] & 65535
        break
      case 'LSHIFT':
        grid[inst.to] = grid[inst.args[0]] << +inst.args[1]
        break
      case 'RSHIFT':
        grid[inst.to] = grid[inst.args[0]] >> +inst.args[1]
        break
    }
  }

  return grid
}

console.log('Document grid status:')
console.log(exec_instructions(parse_instructions(doc)))

const file = await fs.readFile('input')

console.log('Input grid status:')
console.log(exec_instructions(parse_instructions(file.toString())))
