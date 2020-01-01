extern crate rand;

use::std::env;
use::std::process;
use std::io::{self, BufReader};
use std::io::prelude::*;
use std::fs::File;
use rand::Rng;

fn main() -> io::Result < () > {

    let args: Vec < String > = env::args().collect();

    if args.len() == 1 {
        eprintln!("No file name passed");
        process::exit(-1);
    }

    if args.len() > 2 {
        eprintln!("Too many arguments!");
    }

    let f = File::open(args[1].clone())?;
    let f = BufReader::new(f);

    let mut quotes: Vec < String > = Vec::new();

    for line in f.lines() {
        let s = line.unwrap();
        if s.len() > 10 {
            quotes.push(s.to_string());
        }
    }

    let mut rng = rand::thread_rng();
    println!("{}\n", quotes[rng.gen_range(0, quotes.len())]);

    Ok(())
}
