#!/bin/bash

PROGRAM="/home/gen_points.py"
TEST_DIRCTORY="/home/tests/generator_test/"
TESTCASE=(1 2 3 4 5)

for i in "${TESTCASE[@]}"
do
    args=$(<"$TEST_DIRCTORY/test_$i.args")
    output=$(python3 $PROGRAM $args 2>&1)
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