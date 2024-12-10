package main

import (
	"errors"
	"fmt"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

func validate(input string) (int, error) {
	re := regexp.MustCompile("(.*)-([\\d]+)\\[(.*)\\]")

	matches := re.FindStringSubmatch(input)
	room := matches[1]
	id, _ := strconv.Atoi(matches[2])
	checksum := matches[3]

	weights := make(map[rune]int)

	for _, c := range strings.ReplaceAll(room, "-", "") {
		count, ok := weights[c]
		if ok {
			weights[c] = count + 1
		} else {
			weights[c] = 0
		}
	}

	letters := make([]rune, 0, len(weights))
	for l := range weights {
		letters = append(letters, l)
	}

	sort.Slice(letters, func(i, j int) bool {
		a := letters[i]
		b := letters[j]

		if weights[a] == weights[b] {
			return a < b
		} else {
			return weights[a] > weights[b]
		}
	})

	hash := strings.Builder{}
	for _, l := range letters {
		if hash.Len() >= 5 {
			break
		}
		hash.WriteRune(l)
	}

	if hash.String() != checksum {
		return 0, errors.New("Cannot validate the room name")
	}

	return id, nil
}

var doc = []string{
	"aaaaa-bbb-z-y-x-123[abxyz]",
	"a-b-c-d-e-f-g-h-987[abcde]",
	"not-a-real-room-404[oarel]",
	"totally-real-room-200[decoy]",
}

func main() {

	total := 0

	for _, room := range doc {
		id, err := validate(room)
		if err == nil {
			total += id
		}
	}

	fmt.Println("Example sum:", total)

	input, _ := os.ReadFile("input")
	lines := strings.Split(string(input), "\n")

	total = 0

	for _, line := range lines {
		if len(line) == 0 {
			continue
		}

		id, err := validate(line)
		if err == nil {
			total += id
		}
	}

	fmt.Println("Sum of sector ids of real rooms:", total)
}
