#!/bin/bash

check_line() {
  read freq_range ltr password
  ltr=${ltr%:}
  IFS=- read min max <<<$freq_range
  ltrs_in_password=${password//[^$ltr]}
  [[ $min -le ${#ltrs_in_password} && $max -ge ${#ltrs_in_password} ]]
}

num_good=0
while read line; do
  check_line <<<"$line" && let num_good+=1
done
echo $num_good
