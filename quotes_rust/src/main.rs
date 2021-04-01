extern crate rand;
extern crate regex;

use::std::env;
use::std::process;
use std::io::{self, BufReader};
use std::io::prelude::*;
use std::fs::File;
use rand::Rng;
use regex::Regex;

fn main() -> io::Result < () > {

    // load arguments of main function
    let args: Vec < String > = env::args().collect();

    // no arguments means no file name passed
    if args.len() == 1 {
        eprintln!("No file name passed!");
        process::exit(-1);
    }

    // the program requires only one argument
    // that argument ought to be the path to the quote file
    if args.len() > 2 {
        eprintln!("Too many arguments!");
    }

    let f = File::open(args[1].clone())?;
    let f = BufReader::new(f);

/* 
    A quote should match the following format: 
        "text"( - Author's name)
    The part wrapped in () is optional.
    Examples of well formatted quotes:
        "The sky is blue" - Anonymous's Le the 3rd
        " The sky is red "
    Lines NOT starting with quotes (") are ignored.
*/

    // the format is checked using regex
    let quote_re = Regex::new("\"[a-zA-ZéèșȘțȚăĂîÎâÂ1-9.,?!-' ;:]+\"( - [a-zA-Z-'. ]*)?").unwrap();

    let mut quotes: Vec < String > = Vec::new();

    for line in f.lines() {
        let s = line.unwrap();
        if s.len() == 0 {
            continue;
        }

        if quote_re.is_match(&s) {
            quotes.push(s.to_string());
        }
        else if s.chars().nth(0).unwrap() == '"' {
            // a quote will always start with ",
            // so there must be a problem if it is not matched
            eprintln!("quote is not matched:\n{}\n", s);
        }
    }

    // cannot print quote if there are not quotes
    if quotes.len() == 0 {
        eprintln!("No quotes found");
        process::exit(-1);
    }

    let mut rng = rand::thread_rng();
    println!("{}\n", quotes[rng.gen_range(0, quotes.len())]);

    Ok(())
}
