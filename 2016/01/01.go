package main

import (
	"fmt"
	"strconv"
	"strings"
)

var input = "L2, L5, L5, R5, L2, L4, R1, R1, L4, R2, R1, L1, L4, R1, L4, L4, R5, R3, R1, L1, R1, L5, L1, R5, L4, R2, L5, L3, L3, R3, L3, R4, R4, L2, L5, R1, R2, L2, L1, R3, R4, L193, R3, L5, R45, L1, R4, R79, L5, L5, R5, R1, L4, R3, R3, L4, R185, L5, L3, L1, R5, L2, R1, R3, R2, L3, L4, L2, R2, L3, L2, L2, L3, L5, R3, R4, L5, R1, R2, L2, R4, R3, L4, L3, L1, R3, R2, R1, R1, L3, R4, L5, R2, R1, R3, L3, L2, L2, R2, R1, R2, R3, L3, L3, R4, L4, R4, R4, R4, L3, L1, L2, R5, R2, R2, R2, L4, L3, L4, R4, L5, L4, R2, L4, L4, R4, R1, R5, L2, L4, L5, L3, L2, L4, L4, R3, L3, L4, R1, L2, R3, L2, R1, R2, R5, L4, L2, L1, L3, R2, R3, L2, L1, L5, L2, L1, R4"

type Vector2 struct {
	x, y int
}

var ZERO = Vector2{0, 0}
var NORTH = Vector2{0, -1}
var EAST = Vector2{1, 0}
var SOUTH = Vector2{0, 1}
var WEST = Vector2{-1, 0}

func (v Vector2) RotateRight() Vector2 {
	return Vector2{v.y * -1, v.x}
}

func (v Vector2) RotateLeft() Vector2 {
	return Vector2{v.y, v.x * -1}
}

func (v Vector2) Mult(o Vector2) Vector2 {
	return Vector2{v.x * o.x, v.y * o.y}
}

func (v Vector2) Add(o Vector2) Vector2 {
	return Vector2{v.x + o.x, v.y + o.y}
}

func main() {
	if NORTH.RotateLeft() != WEST {
		panic("NORTH rotated left is supposed to equal WEST")
	}

	if NORTH.RotateRight() != EAST {
		panic("NORTH rotated right is supposed to equal EST")
	}

	strs := strings.Split(input, ", ")

	pos := ZERO
	dir := NORTH

	for _, move := range strs {
		switch string(move[0]) {
		case "L":
			dir = dir.RotateLeft()
		case "R":
			dir = dir.RotateRight()
		}

		dist, _ := strconv.Atoi(move[1:])
		pos = pos.Add(dir.Mult(Vector2{dist, dist}))
	}

	fmt.Println(pos.x + pos.y)
}
