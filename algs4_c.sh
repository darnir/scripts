#!/bin/bash

cat >> ~/.bashrc << EOF
algs4c() {
    if (checkstyle-algs4 "$1.java")
    then
        echo "CheckStyle Passed..."
        if (javac-algs4 "$1.java")
        then
            echo "Compilation Successful..."
            if (findbugs-algs4 "$1.class")
            then
                echo "No bugs Found..."
                return 0
            else
                echo "Findbugs Failed!"
                return 103
            fi
        else
            echo "Compilation Failed!"
            return 102
        fi
    else
        echo "CheckStyle Failed!"
        return 101
    fi
}

algs4cr() {
    if (algs4c "$1")
    then
        java-algs4 "$1"
    else
        reurn $?
    fi
}
EOF
