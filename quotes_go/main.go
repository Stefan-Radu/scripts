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

    // try to open file
	file, err := os.Open(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
	defer file.Close()

    // just end in a punctuation mark
	regularExpression := `.*[\.!?]`

	re := regexp.MustCompile(regularExpression)

	idx := 1
	var foundErrors bool = false
    var expect = "quote"
	var quotes []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		txt := scanner.Text()

        if expect == "quote" {
            res := re.Find([]byte(txt))
            if res == nil && txt != "" {
                fmt.Fprintf(os.Stderr, "Format error at line %d: `%s`\n" +
                    "Check ending punctuation.\n", idx, txt)
                foundErrors = true
            } else if txt != "" {
                quotes = append(quotes, "\"" + string(res) + "\"")
            } else {
                fmt.Fprintf(os.Stderr, "Line %d is empty. Expecting quote.\n", idx)
                foundErrors = true
                break
            }
            expect = "author"
        } else if expect == "author" {
            if txt != "" {
                quotes[len(quotes) - 1] += " - " + string(txt)
                expect = "blank"
            } else if txt == "" {
                quotes[len(quotes) - 1] += " - Unknown Author"
                expect = "quote"
            }
        } else if expect == "blank" {
            if txt != "" {
                fmt.Fprintf(os.Stderr, "Error at line %d. Expecting blank line.\n", idx)
                foundErrors = true
                break
            }
            expect = "quote"
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
