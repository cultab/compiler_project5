#!/bin/sh

for test in ./tests/*; do
    echo "$test"
    echo ''
    echo '```python'
    cat "$test"
    echo '```'
    echo ''
    echo '```default'
    ./pyparse "$test"
    echo '```'
    echo ''
done
