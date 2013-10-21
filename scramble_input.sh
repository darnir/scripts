#!/bin/bash

LINES=50
INFILE=convo.txt
TEXTFILE=pg100.txt
MAXLINES=500
TEMPFILE=tmpfile.txt

for i in $(seq 1 200)
do
    OUTFILE=$(cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c 8)
    shuf ${INFILE} > ${TEMPFILE} && awk 'BEGIN{srand(); m=int(rand()*100+1)} FNR==NR{a[NR]=$0;next} FNR % m == 0 && ++i in a{print a[i];m=int(rand()*5000+1)} {print}' ${TEMPFILE} ${TEXTFILE} > ${OUTFILE}
FI=$(grep -f d ${OUTFILE} | wc -l)
if [ "$FI" -ne 25 ];
    then
        i=$((i--))
        echo $i
    fi
done
