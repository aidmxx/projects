#!/bin/bash

# Get the current directory
CURRENT_DIR=$(pwd)

# Define variables
PROGRAM_NAME="pkgmain"                    # The name of the compiled program
PROGRAM="$PROGRAM_NAME"                   # The program to run after moving to the current directory
INPUT="test5.bpkg"                        # The input .bpkg file
FLAG="-hashes_of"                         # The flag for the program
EXPECTED_OUTPUT="merk_test5.out"          # The name of the expected output file
ACTUAL_OUTPUT="actual_output.out"         # Temporary file for actual output
HASH="3b7546ed79e3e5a7907381b093c5a182cbf364c5dd0443dfa956c8cca271cc33" # The hash for testing

# Navigate to the directory containing the Makefile and compile the program
echo "Compiling $PROGRAM_NAME..."

cd ../../..
make $PROGRAM_NAME
if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Ensure the program is executable
chmod +x $PROGRAM

# Check if input file exists
if [ ! -f "$CURRENT_DIR/$INPUT" ]; then
    echo "Input file $CURRENT_DIR/$INPUT not found."
    exit 1
fi

# Run the program with the specified input and flag, redirecting output to ACTUAL_OUTPUT
echo "Running $PROGRAM with input $CURRENT_DIR/$INPUT and flag $FLAG..."
./$PROGRAM $CURRENT_DIR/$INPUT $FLAG $HASH > $CURRENT_DIR/$ACTUAL_OUTPUT
if [ $? -ne 0 ]; then
    echo "Program failed to run."
    exit 1
fi

# Find the number of lines in a file
num_lines=$(wc -l < "$CURRENT_DIR/$ACTUAL_OUTPUT")
echo "Number of children: $num_lines" >> "$CURRENT_DIR/$ACTUAL_OUTPUT"

# Add newline to the end of files if missing
sed -i -e '$a\' "$CURRENT_DIR/$ACTUAL_OUTPUT"
sed -i -e '$a\' "$CURRENT_DIR/$EXPECTED_OUTPUT"

# Compare the modified actual output with the expected output
if diff "$CURRENT_DIR/$ACTUAL_OUTPUT" "$CURRENT_DIR/$EXPECTED_OUTPUT"; then
    echo "Success! No differences found :)"
else
    echo "Failure. Please check the following differences:"
    echo "Expected output ($CURRENT_DIR/$EXPECTED_OUTPUT):"
    cat "$CURRENT_DIR/$EXPECTED_OUTPUT"
    echo ""
    echo "-----------------------------------"
    echo "Actual output ($CURRENT_DIR/$ACTUAL_OUTPUT):"
    cat "$CURRENT_DIR/$ACTUAL_OUTPUT"
fi

# Clean up the temporary files and the compiled program
echo "Cleaning up..."
rm -f $CURRENT_DIR/$ACTUAL_OUTPUT $PROGRAM

echo "Done."
