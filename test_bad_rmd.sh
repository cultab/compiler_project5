#!/bin/sh

for test in ./tests/*; do
    echo '```python'
    cat "$test"
    echo '```'
    echo '```default'
    ./pyparse "$test"
    echo '```'
done
