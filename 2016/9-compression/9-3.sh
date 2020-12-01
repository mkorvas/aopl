#!/bin/bash

function str_find() {
  local str=$1 char=$2
  local stripped=$(eval echo "\${str#*\\$char}")
  echo $((${#str} - ${#stripped} - 1))
}

function decompress_count() {
  local in=$(eval echo "\${in$depth}")
  local next_lparen_idx=$(str_find "$in" '(')
  local lcount=0
  case $next_lparen_idx in
    -1) lcount=${#in}
        in=
        ;;
    0)  local next_rparen_idx=$(str_find "$in" ')')
        local marker=${in:1:$(($next_rparen_idx - 1))}
        # Strip the marker.
        in=${in:$(($next_rparen_idx + 1))}
        # decompress-count the sequence.
        local seq="${in:0:${marker%x*}}"
        depth=$(($depth + 1))
        eval "in$depth=$(printf %q "$seq")"
        eval "count$depth=0"
        while [[ $(eval echo "\${#in$depth}") -gt 0 ]]; do
          decompress_count
        done
        eval "lcount=\$((\${marker#*x} * \$count$depth))"
        depth=$(($depth - 1))
        # Strip the sequence
        in=${in:${marker%x*}}
        ;;
    *)  lcount=$next_lparen_idx
        in=${in:$next_lparen_idx}
  esac
  eval "count$depth=\$((\$count$depth + $lcount))"
  eval "in$depth=\$in"
}

in0=$(<"$1")
count0=0
depth=0

while [[ $in0 ]]; do
  decompress_count
done

echo "$count0"


# $ /usr/bin/time ./9-3.sh in
# 10931789799
# 0.64user 9.65system 0:09.13elapsed 112%CPU (0avgtext+0avgdata 2020maxresident)k
# 0inputs+0outputs (0major+4213673minor)pagefaults 0swaps
