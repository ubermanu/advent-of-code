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
    const [, cmd, to] = line.match(/^(.*)\s->\s(\w+)$/) ?? []

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

class Gate {
  active = false
  type: Instruction['type']
  inputs: Array<number | Wire> = []
  output: Wire
}

class Wire {
  value: number | undefined = undefined
  inputs: Gate[] = []

  connect(input: Gate): void {
    input.output = this
    this.inputs.push(input)
  }
}

class Circuit {
  wires: Map<string, Wire> = new Map()
}

function is_number(str: string): boolean {
  return /^\d+$/.test(str)
}

function connect_wires(instructions: Instruction[]): Circuit {
  const c = new Circuit()

  const wire_names = [... new Set(instructions.map(({ to }) => to))]

  for (let name of wire_names) {
    c.wires.set(name, new Wire())
  }

  for (let inst of instructions) {
    const g = new Gate()
    g.type = inst.type

    inst.args.forEach(arg => {
      if (is_number(arg)) {
        g.inputs.push(+arg)
      } else {
        g.inputs.push(c.wires.get(arg)!)
      }
    })

    c.wires.get(inst.to)?.connect(g)
  }

  return c
}

const value = (v: Wire | number) => typeof v === 'number' ? v : v.value!

function run_circuit(circuit: Circuit) {
  let run = true

  while (run) {
    run = false

    circuit.wires.forEach((wire) => {
      wire.inputs.forEach((gate) => {

        // Check if the gate can be activated
        for (let input of gate.inputs) {
          if (input instanceof Wire && input.value === undefined) {
            // console.log("One of the gate inputs has no value yet")
            run = true
            return
          }
        }

        const [arg1, arg2] = gate.inputs

        switch (gate.type) {
          case 'SET':
            wire.value = value(arg1)
            break
          case 'AND':
            wire.value = value(arg1) & value(arg2)
            break
          case 'OR':
            wire.value = value(arg1) | value(arg2)
            break
          case 'NOT':
            wire.value = ~value(arg1) & 65535
            break
          case 'LSHIFT':
            wire.value = value(arg1) << value(arg2)
            break
          case 'RSHIFT':
            wire.value = value(arg1) >> value(arg2)
            break
        }
      })
    })
  }

  console.log(circuit_values(circuit))
}

function circuit_values(circuit: Circuit): Record<string, number> {
  return Object.fromEntries(
    Array
      .from(circuit.wires.entries())
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([name, wire]) => ([name, wire.value!]))
  )
}

console.log('Document grid status:')
let circuit = connect_wires(parse_instructions(doc));
run_circuit(circuit)

const file = await fs.readFile('input')

console.log('Input grid status:')
let circuit2 = connect_wires(parse_instructions(file.toString()));
run_circuit(circuit2)

