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
REGEX="\"([\w' .,;:țșîăâè\!?])+[\.?!]\",( [\w 'țșîăâè\-.]+)?"

# check for missmatches
not_matched_count=$(grep -cvP "$REGEX" $1)

if [[ $not_matched_count -ne 1 ]]; then
  not_matched=$(grep -nvP "$REGEX" $1)
  nl_index=$(expr index "$not_matched" $'\n')
  not_matched=${not_matched:$nl_index}
  echo -e "The following lines are not formatted properly\n\n$not_matched\n\nFix them asap."
  exit -1
fi

# store in array
lines=()

while read line; do
  lines+=("$line")
  # this is very slow so I commented it out
  # match=$(grep -P "$REGEX" <<< $line)
  # diff -s <(echo $match) <(echo $line) >> /dev/null
  # [[ $cnt -gt 1 && $? -eq 1 ]] &&
  # echo -e "line $cnt not is not formatted properly.\n$line\nFix it asap." &&
  # exit -1
done < <(cat $1)

lines_cnt=$((${#lines[@]} - 1))
index=$(($RANDOM%$lines_cnt + 1))

# reverse line
rev_line=$(echo ${lines[$index]} | rev)

# format quotes to look like a quote
if [[ -z "${rev_line%%,*}" ]]; then
  to_print=$(echo ${rev_line/[,]/} | rev)
else
  to_print=$(echo ${rev_line/[,]/ - } | rev)
fi

# print
echo $to_print
