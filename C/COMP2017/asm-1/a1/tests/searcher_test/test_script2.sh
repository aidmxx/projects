#!/bin/bash

PROGRAM="smallest_triangle"
TEST_DIRCTORY="/home/tests/searcher_test"
TESTCASE=(1 2 3 4 5)
#PATH="/Users/y2l/a1/${PROGRAM}"

for i in "${TESTCASE[@]}"
do
    expected="$TEST_DIRCTORY/test_$i.out"
    echo "Currently running test $i"
    echo "Expected:"
    cat "$expected"
    echo "Output:"
    if ! ./$PROGRAM < "$TEST_DIRCTORY/test_$i.in"
    then
        echo "Test $i not passed"
    else
        echo "Testcase $i successfully"
    fi
    echo "======================="
done