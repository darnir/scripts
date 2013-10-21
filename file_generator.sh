#!/bin/bash

for i in $(seq 1 60000)
do
    FNAME=$(cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c 8)
    str=0
    for j in $(seq 1 19)
    do
         NUM=$(( ( RANDOM % 19 )  + 1 ))
         str=${str}${NUM}
    done
    echo ${str} > $FNAME
done
