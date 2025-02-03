#!/bin/bash

# Base directory containing the test directories
BASE_DIR="tests/p2test"

# Find all directories in the BASE_DIR matching the pattern test*
for TEST_DIR in "$BASE_DIR"/test*; do
    # Check if the found path is a directory
    if [ -d "$TEST_DIR" ]; then
        # Check if the run_test.sh script exists in the test directory
        if [ -f "$TEST_DIR/run_test.sh" ]; then
            echo "Running run_test.sh in $TEST_DIR..."
            (cd "$TEST_DIR" && chmod +x run_test.sh && ./run_test.sh)
            if [ $? -ne 0 ]; then
                echo "Error running run_test.sh in $TEST_DIR"
            fi
        else
            echo "run_test.sh not found in $TEST_DIR"
        fi
    else
        echo "$TEST_DIR is not a directory"
    fi
done
