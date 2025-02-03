#!/bin/bash

# Get the current directory
CURRENT_DIR=$(pwd)

# Define variables
PROGRAM_NAME="pkgmain"                    # The name of the compiled program
PROGRAM="$PROGRAM_NAME"                   # The program to run after moving to the current directory
INPUT="test3.bpkg"                        # The input .bpkg file
FLAG="-all_hashes"                        # The flag for the program
EXPECTED_OUTPUT="merk_test3.out"          # The name of the expected output file
ACTUAL_OUTPUT="actual_output.out"         # Temporary file for actual output
TEMP_OUTPUT="temp_output.out"             # Temporary file for modified actual output

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
./$PROGRAM $CURRENT_DIR/$INPUT $FLAG > $CURRENT_DIR/$ACTUAL_OUTPUT
if [ $? -ne 0 ]; then
    echo "Program failed to run."
    exit 1
fi

# Keep only the first line corresponding to nhashes from the top of the actual output
head -n 1 "$CURRENT_DIR/$ACTUAL_OUTPUT" > "$CURRENT_DIR/$TEMP_OUTPUT"

# Append the length to the end of the TEMP_OUTPUT file
length=$(wc -c < "$CURRENT_DIR/$TEMP_OUTPUT")
echo "Length of characters: $length" >> "$CURRENT_DIR/$TEMP_OUTPUT"

# Add newline to the end of files if missing
sed -i -e '$a\' "$CURRENT_DIR/$TEMP_OUTPUT"
sed -i -e '$a\' "$CURRENT_DIR/$EXPECTED_OUTPUT"

# Compare the modified actual output with the expected output
if diff "$CURRENT_DIR/$TEMP_OUTPUT" "$CURRENT_DIR/$EXPECTED_OUTPUT"; then
    echo "Success! No differences found :)"
else
    echo "Failure. Please check the following differences:"
    echo "Expected output ($CURRENT_DIR/$EXPECTED_OUTPUT):"
    cat "$CURRENT_DIR/$EXPECTED_OUTPUT"
    echo ""
    echo "-----------------------------------"
    echo "Actual output ($CURRENT_DIR/$TEMP_OUTPUT):"
    cat "$CURRENT_DIR/$TEMP_OUTPUT"
fi

# Clean up the temporary files and the compiled program
echo "Cleaning up..."
rm -f $CURRENT_DIR/$ACTUAL_OUTPUT $CURRENT_DIR/$TEMP_OUTPUT $PROGRAM

echo "Done."
