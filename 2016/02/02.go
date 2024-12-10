package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

var keypad = [3][3]int{
	{1, 2, 3},
	{4, 5, 6},
	{7, 8, 9},
}

var doc = `ULL
RRDDD
LURDL
UUUUD`

type Vector2 struct {
	x, y int
}

func min(a int, b int) int {
	if a < b {
		return a
	} else {
		return b
	}
}

func max(a int, b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}

func guess_code(input string) string {
	lines := strings.Split(input, "\n")
	pos := Vector2{1, 1}
	code := strings.Builder{}

	for _, line := range lines {
		if len(line) == 0 {
			continue
		}

		for _, char := range line {
			switch string(char) {
			case "U":
				pos.y -= 1
			case "R":
				pos.x += 1
			case "D":
				pos.y += 1
			case "L":
				pos.x -= 1
			default:
				panic("Unknown character")
			}

			pos.x = max(0, min(pos.x, 2))
			pos.y = max(0, min(pos.y, 2))
		}

		code.WriteString(strconv.Itoa(keypad[pos.y][pos.x]))
	}

	return code.String()
}

func main() {
	fmt.Println(guess_code(doc))

	input, err := os.ReadFile("input")
	if err != nil {
		panic(err)
	}
	fmt.Println(guess_code(string(input)))
}
