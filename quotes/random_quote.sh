#!/bin/sh

#colors
RED='\033[0;31m'
NC='\033[0m' # No Color

usage="$(basename "$0") [options] -f file_path

usage:
    -f  input file
    -i  show information regarding the expected file format
    -h  show this help text

Cute script ^^ which prints out a random quote from a formatted file."

format_info="\
+------------------------------------------------------------------------+
| The input file should be formatted as follows:                         |
| * All quotes start with 'q:' and span a whole line                     |
| * All quote lines are (optionally) followed by an author line          |
| * All author lines start with 'a:'                                     |
| * All other lines are ignored                                          |
+------------------------------------------------------------------------+"


#################
# Parse options #
#################

while getopts ':hif:' OPTION; do
    case "$OPTION" in
        h)
            echo "$usage"
            exit 0
            ;;
        i)
            echo "$format_info"
            exit 0
            ;;
        f) 
            file=$OPTARG
            ;;
        :) 
            printf "missing argument for -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
        \?) 
            printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND - 1))"

##############
# Check file #
##############

if [ -z "$file" ]; then
    echo -e "${RED}give path!!\n${NC}"
    echo "$usage"
    exit 1
elif [ ! -e "$file" ]; then
    echo -n "${RED}!!!but it doens't exist!!!!${NC}"
    exit 1
elif [ ! -f "$file" ]; then
    echo "${RED}not a file??${NC}"
    exit 1
elif [ ! -r "$file" ]; then
    echo "${RED}!!can't reeaaaaaaaaaaaaaadddd!!!!${NC}"
    exit 1
fi

#####################
# Get a radom quote #
#####################

# get random line
random_line=$(grep -En "^q:" $file | shuf -n 1)
# only quote without the header and line number
quote=$(echo "$random_line" | sed -r "s%[0-9]+:q:%%")
# only the line number
line_nubmer=$(grep -Eo "^[0-9]+" <<< "$random_line")
# line following the quote (check for author)
next_line=$(sed "$((($line_nubmer+1)))q;d" $file)

# if the line starts with "a:" it is the author
if [ -n "$(echo "$next_line" | grep -E "^a:")" ]; then
    # only author, no header
    author=$(cut -c 3- <<< "$next_line")
    printf "> %s\n- %s" "$quote" "$author"
else 
    # print quote without author
    echo -n "> $quote"
fi
