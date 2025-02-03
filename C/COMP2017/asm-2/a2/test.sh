#!/bin/bash

PROGRAM="mtll"
TEST_DIRECTORY="/home/tests"
TESTCASE=(1 2 3)
#PATH="/Users/y2l/multi-type-linked-list-scaffold/tests/${PROGRAM}"

for i in "${TESTCASE[@]}"
do
    expected="$TEST_DIRECTORY/test_$i.out"
    input="$TEST_DIRECTORY/test_$i.in"
    echo "Currently running test $i"
    echo "Expected:"
    cat "$expected"
    echo "Output:"
    if ! ./$PROGRAM < "$input"; then
        echo "Runtime error on test $i"
        continue
    fi 
    output=$(./$PROGRAM < "$input")
    if [ "$output" == "$(cat $expected)" ]; then
        echo "Testcase $i passed successfully"
    else
        echo "Test $i failed"
    fi
    echo "======================="
done
