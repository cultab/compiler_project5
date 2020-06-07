#!/bin/sh

for test in ./tests/*; do
    echo "Running test for $test."
    echo "------------------------------------"
    cat "$test"
    echo "------------------------------------"
    ./pyparse "$test"
    echo "------------------------------------"
done
