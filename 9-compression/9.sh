#!/bin/bash

function str_find() {
  local str=$1 char=$2
  local stripped=$(eval echo "\${str#*\\$char}")
  echo $((${#str} - ${#stripped} - 1))
}

function decompress_count() {
  local next_lparen_idx=$(str_find "$in" '(')
  case $next_lparen_idx in
    -1) count=$(($count + ${#in}))
        in=
        ;;
    0)  local next_rparen_idx=$(str_find "$in" ')')
        marker=${in:1:$(($next_rparen_idx - 1))}
        # echo >&2 "marker=$marker"
        # Strip the marker.
        in=${in:$(($next_rparen_idx + 1))}
        # Strip the sequence.
        # for ((i=0; i<${marker#*x}; i++)); do
        #   echo >&2 "${in:0:${marker%x*}}"
        # done
        in=${in:${marker%x*}}
        # Count the decompressed sequence
        count=$(($count + ${marker#*x} * ${marker%x*}))
        ;;
    *)  count=$(($count + $next_lparen_idx))
        in=${in:$next_lparen_idx}
  esac
}

in=$(<"$1")
count=0

while [[ $in ]]; do
  decompress_count
done

echo "$count"
