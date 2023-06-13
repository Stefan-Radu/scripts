# Quotes script thingie

###### tl;dr
This is an extremely simple script which prints out a random quote from a custom
formatted file.

## About

I've been using this for a few years already and decided to write it out
properly. At first I've written multiple variants of it to experiment with
different programming languages from bash (very poor quality bash), to rust
(also very poor quality rust) and golang. 

I decided to rewrite it properly and used `shell` to better grasp the differences 
between it and `bash` (and also claim that it's more portable). I also introduced 
a properly defined format for the quotes file, as this was also rather random
and undefined.

### File Format

The input file should be formatted as follows:  
* All quotes start with 'q:' and span a whole line  
* All quote lines are (optionally) followed by an author line  
* All author lines start with 'a:' 
* All other lines are ignored  

### File format example 

    this line is ignored
    q:dogs have no idea what's going on and I am so gealous of them
    
    also this line is ignored. also above is a quote without an author
    below is a quote with an author

    q:In order to win, you mustn't lose.
    a:Rambo Amadeus

### Example output (for file above)

In order to win, you mustn't lose.   
\- Rambo Amadeus

## Example usage

This is how I've been using it:
`random_quote -f $QUOTES_PATH | cowsay -f tux | lolcat -F 0.2 -t`

### Requirements
 
* cowsay (for cow)
* lolcat (for rainbow)

Use as you desire.
