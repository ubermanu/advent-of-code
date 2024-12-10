package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	input, _ := os.ReadFile("input")
	lines := strings.Split(string(input), "\n")
	count := 0

	for _, line := range lines {
		if len(line) == 0 {
			continue
		}

		a, _ := strconv.Atoi(strings.Trim(line[2:5], " "))
		b, _ := strconv.Atoi(strings.Trim(line[7:11], " "))
		c, _ := strconv.Atoi(strings.Trim(line[12:15], " "))

		fmt.Println(a, b, c)

		if (a+b > c) && (a+c > b) && (b+c > a) {
			count += 1
		}
	}

	fmt.Println("Valid trianges:", count)
}
