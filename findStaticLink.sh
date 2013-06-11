#!/bin/bash

for f in `ls /usr/bin`
do
    if [ -f /usr/bin/$f ]
    then
        readelf -d /usr/bin/$f | grep libpng15.so.15 > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo $(pacman -Qo -q /usr/bin/$f)
        fi
    fi
done
