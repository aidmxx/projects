#!/bin/bash

GENERATOR="/home/gen_points.py"
SEARCHER="smallest_triangle"
TEST_DIRCTORY="/home/tests/E2E_test"
TESTCASE=(1 2 3 4 5)

for i in "${TESTCASE[@]}"
do
    args=$(cat "$TEST_DIRCTORY/test_$i.args")
    # tee /dev/tty writes the output from python3 to TTY and allow to see the output in real-time
    output=$( (python3 $GENERATOR $args | ./$SEARCHER) 2>&1 | tee /dev/tty)
    expected=$(<"$TEST_DIRCTORY/test_$i.out")

    echo "Currently running test $i"
    echo "Expected:"
    echo "$expected"
    echo "Output:"
    echo "$output"
    if [ "$output" == "$expected" ]; then
        echo "Testcase $i successfully"
    else
        echo "Test $i not passed"
    fi
    echo "======================="
done