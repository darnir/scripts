#!/bin/bash

rm pid sigs sig_array db.txt
echo -n "const char *sig_db[] = {" > sig_array
for i in $(seq 1 40)
do
    ID=
    for j in $(seq 1 3)
    do
        INO=$(( ( RANDOM % 9 )  + 1 ))
        ID=${ID}${INO}
    done
    echo ${ID} >> pid
    SIG=$(cat /dev/urandom | tr -dc 'a-zA-Z' | head -c 2)
    echo ${SIG} >> sigs
    echo ${ID}:${SIG} >> db.txt
    echo -n \"${SIG}\", >> sig_array
done

for i in $(seq 1 10)
do
    SIG=$(cat /dev/urandom | tr -dc 'a-zA-Z' | head -c 2)
    echo ${SIG} >> sigs
    echo -n \"${SIG}\", >> sig_array
done
echo \b"};" >> sig_array
