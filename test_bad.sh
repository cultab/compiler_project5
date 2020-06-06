#!/bin/sh

for test in ./tests/*.txt; do
    echo "Running test for $test."
    echo "------------------------------------"
    ./pyparse "$test"
    echo "------------------------------------"
done
