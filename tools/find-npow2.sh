#!/bin/bash

function check_npow2 {
    ans=`python -c "import math; l = math.log($1) / math.log(2.0); print(2**int(l) != $1)"`
    if [ "$ans" == "True" ]; then
        echo "1"
    else
        echo "0"
    fi
}

for file in textures/*; do
    x_res=`identify $file | sed -E -n 's/.* ([0-9]+)x[0-9]+\+[0-9]+\+[0-9]+ .*/\1/p'`
    y_res=`identify $file | sed -E -n 's/.* [0-9]+x([0-9]+)\+[0-9]+\+[0-9]+ .*/\1/p'`
    npow_x=`check_npow2 $x_res`
    npow_y=`check_npow2 $y_res`
    if [ "$npow_x" == "1" -o "$npow_y" == "1" ]; then
        echo "`basename $file`: non-pow2 dimensions: ${x_res}x${y_res}"
    fi
done
