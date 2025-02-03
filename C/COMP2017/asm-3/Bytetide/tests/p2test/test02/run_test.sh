#!/bin/bash

# Get the current directory
CURRENT_DIR=$(pwd)

# Define variables
PROGRAM_NAME="btide"                    # The name of the compiled program
CONFIG_FILE="config.cfg"                # Define the configuration file
PROGRAM="$PROGRAM_NAME"                 # The program to run after moving to the current directory
INPUT="test2.bpkg"                      # The input .bpkg file
EXPECTED_OUTPUT="conn_test2.out"        # The name of the expected output file
ACTUAL_OUTPUT="actual_output.out"       # Temporary file for actual output

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

# Run the program with the specified input and flag, redirecting output to ACTUAL_OUTPUT
echo "Running $PROGRAM with input $INPUT..."
./$PROGRAM $CONFIG_FILE <<EOF > "$CURRENT_DIR/$ACTUAL_OUTPUT"
CONNECT 192.168.1.1:9000
QUIT
EOF

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
rm -f "$CURRENT_DIR/$ACTUAL_OUTPUT" $PROGRAM

echo "Done."
