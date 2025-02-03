#!/bin/bash

PROGRAM="./pkgmain"   
INPUT="test9.bpkg"     
FLAG="-all_hashes"       
EXPECTED_OUTPUT="bpkg_test9.out"
ACTUAL_OUTPUT="actual_output.out"

# give a perimission
chmod +x $PROGRAM
$PROGRAM $INPUT $FLAG > $ACTUAL_OUTPUT

diff $ACTUAL_OUTPUT $EXPECTED_OUTPUT

if [ $? -eq 0 ]; then
    echo "Successfully! No differences at all :)"
else
    echo "Failed. Plsease check the following differences."
    echo "Expected output ($EXPECTED_OUTPUT):"
    cat $EXPECTED_OUTPUT
    echo ""
    echo "-----------------------------------"
    echo "Actual output ($ACTUAL_OUTPUT):"
    cat $ACTUAL_OUTPUT
fi

# clean up
rm -f $ACTUAL_OUTPUT
