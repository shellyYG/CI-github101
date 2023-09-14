package main

import (
	"fmt"
	"strings"
)

func main() {
	trimmed := trimWords("ATB124")
	fmt.Println(trimmed)
}

func trimWords(words string) string {
	return strings.TrimPrefix(words, "ATB")
}