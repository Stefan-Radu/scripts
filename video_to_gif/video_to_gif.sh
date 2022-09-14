#!/bin/bash

input_file=
output_file=
skip_seconds=
to_seconds=
fps=15
scale=480

while getopts ":i:o:s:t:f:z:" opt; do
  case $opt in
    i) input_file="$OPTARG" #input
    ;;
    o) output_file="$OPTARG" #output
    ;;
    s) skip_seconds="$OPTARG" #skip seconds
    ;;
    t) to_seconds="$OPTARG" #to seconds
    ;;
    f) fps="$OPTARG" #fps
    ;;
    z) scale="$OPTARG" #zoom / scale
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if [[ $# -eq 0 ]]; then
    help_message="Use the following options:
    -i: input file [mandatory]
    -o: output file [mandatory]
    -s: skip seconds [optional, default none]
    -t: to seconds [optional, default none]
    -f: fps [optional, default 15]
    -z: scale [optional, default 480]"

    echo "$help_message"

    exit 0
fi

if [[ -z $input_file ]]; then
    echo "input file required. use -i"
    exit -1
fi

if [[ -z $output_file ]]; then
    echo "output file required. use -o"
    exit -1
fi

echo "Generating to gif..."

ffmpeg -y -ss $skip_seconds -to $to_seconds -i $input_file -filter_complex "fps=$fps,scale=$scale:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=32[p];[s1][p]paletteuse=dither=bayer" $output_file

file_size=$(stat -c %s $output_file)

echo "Output file size: $file_size bytes"
