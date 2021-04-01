#!/bin/bash

# check if number of argument is right
if [[ $# -lt 1 ]]; then
  echo 'Path argument required.'
  exit -1
elif [[ $# -ne 1 ]]; then
  echo 'Accepts exactly one argument.'
fi

# check if path exists, if there is a file and is readable
if [[ ! -e $1 || ! -f $1 || ! -r $1 ]]; then
  echo 'Invalid path.'
  exit -1
fi

# regex for right quote format
REGEX="^([\w' .;:țșîăâè\!?])+\.,( [\w 'țșîăâè\-.]+)?$"

cnt=0
lines=()

# store in array
# report any missmatching quotes
while read line; do
  cnt=$((cnt+1))

  match=$(grep -P "$REGEX" <<< $line)
  diff -s <(echo $match) <(echo $line) >> /dev/null

  [[ $cnt -gt 1 && $? -eq 1 ]] &&
  echo -e "line $cnt not is not formatted properly.\n$line\nFix it asap." &&
  exit -1

  lines+=("$line")
done < <(cat $1)

lines_cnt=${#lines[@]}
index=$(($RANDOM%$lines_cnt))
comma_index=$(expr index "${lines[$index]}" ",")

# format quotes to look like a quote
if [[ $comma_index -eq ${#lines[$index]} ]]; then
  to_print="\"${lines[$index]/[,]/\"}"
else
  to_print="\"${lines[$index]/[,]/\" - }"
fi

# print
echo $to_print
