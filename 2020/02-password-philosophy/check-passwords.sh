#!/bin/bash

check_line() {
  read freq_range ltr password
  ltr=${ltr%:}
  IFS=- read min max <<<$freq_range
  ltrs_in_password=${password//[^$ltr]}
  [[ $min -le ${#ltrs_in_password} && $max -ge ${#ltrs_in_password} ]]
}

check_line2() {
  read freq_range ltr password
  ltr=${ltr%:}
  IFS=- read pos1 pos2 <<<$freq_range
  pw_ltr1=${password:$(($pos1-1)):1}
  pw_ltr2=${password:$(($pos2-1)):1}
  [[ $pw_ltr1 == $ltr && $pw_ltr2 != $ltr ||
     $pw_ltr2 == $ltr && $pw_ltr1 != $ltr ]]
}

num_good=0
while read line; do
  check_line2 <<<"$line" && let num_good+=1
done
echo $num_good
