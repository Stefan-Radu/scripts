package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"regexp"
	"time"
)

func main() {
	args := os.Args
	args = args[1:]

	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Path argument required.")
		os.Exit(1)
	} else if len(args) > 1 {
		fmt.Fprintln(os.Stderr, "Extra aguments ignored. More than 1 passed.")
	}

	var path string = args[0]
	fmt.Println(path)

	file, err := os.Open(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
	defer file.Close()

	regularExpression := `> \".*[\.!?]\" -( .*)?`
	re := regexp.MustCompile(regularExpression)

	idx := 1
	var foundErrors bool = false
	var quotes []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		txt := scanner.Text()
		res := re.Find([]byte(txt))
		if res == nil && txt != "" {
			fmt.Fprintf(os.Stderr, "error at line %d: `%s`\n", idx, txt)
			foundErrors = true
		} else if txt != "" {
			quotes = append(quotes, string(res)[2:])
		}
		idx += 1
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if foundErrors == true {
		os.Exit(1)
	}

	rand.Seed(time.Now().UnixNano())
	idx = rand.Intn(len(quotes))
	fmt.Print(quotes[idx])
}
