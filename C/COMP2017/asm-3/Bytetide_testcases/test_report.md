# Author
Yilin Li

# Date 
Thu May 9 20:59:17 AEST 2024
date -u | xargs -I {} sh -c "TZ='Australia/Sydney' date -d '{}'"

# AI used (yes/no)
yes. ChatGPT 3.5

# AI link
https://chat.openai.com

# Instruction
All .bpkg file in here are compiled by using pkgmake binary file. The following command given on Ed workspace shows how to generate a .data file and then generate a .bpkg file based on that .data file.
To generate a data file:
HOWLONG=512 # bytes
FILENAME=data
cat /dev/urandom | head -c $HOWLONG > $FILENAME
xxd $FILENAME

To generate a bpkg file:
./pkgmake < .data file path > --nchunks <number> --output <bpkg filename>.bpkg

Moreover, because the tested programme doesn't finish, the pkgmain binary file used in this test is not effective. This is where the pkgmain binary file serves as a guide to indicate which testcase section should use it.


# Test 1 Description - Computed non-leaf node hash value correctness
The expected Merkle tree structure is that the hash of each non-leaf node is equal to the combination of the hashes of its left and right child nodes. In this section I will provide the hash value of a non-leaf node, and then I will apply the relevant function to find and return its 2 children in the already created Merkle tree. And I need to test the 2 child nodes created by the Merkle tree against the expected .bpkg file to see if the resulting Merkle tree has this correct structure.

The input is the generated expected .bpkg file, which is used here for comparison with the generated Merkle tree.

I will look up the provided non-leaf nodes and return their left, right hashes respectively.

# Test 2 Description - Computed hashes in right size and correct value
I'm testing whether the hash value calculated by the Megalodon node has the correct character size and accuracy, which should be SHA256 Hexadecimal size and 64-characters.When the node is found in the megalite tree, it is compared with its expected hash.

The input is the generated expected .bpkg file to generate a Merkle tree.

The expected result is the expected hash value in .bkpg file to compare with the node's computed hash value found in the Merkle tree.

# Test 3 Description - Merkle tree root hash value character correctness
The root hash value of the Merkle tree should be the total combination of its offspring. The test focuses on seeing whether the generated megalite tree has the correct root hash value.

The input is the expected .bpkg file, and according to the description in the specification, the first line of the hashes is the value of the Merkle tree root.

For expected output, the tree root hash value given in the .bpkg file.

# Test 4 Description - Merkle tree expected hash correctness
The expected hash value for each node in the Merkle tree is the corresponding hash value in the stored.bpkg file.In this section, test whether the expected hash value stored in the node matches the .bpkg file.

The input of this part is is the generated expected .bpkg file that used to detect the random node in the generated Merkle tree.

And the expected outcome is the hash value given in the expectations generated .bpkg file for reference.

# Test 5 Description - Empty non-leaf nodes hashes exists
The hash values of all other non-leaf nodes are obtained by performing a hash operation on the hash values of their children. If it is assumed that the hash values of the child nodes obtained in the hash operation part are valid and error-free, but if the generated hash values of the non-leaf nodes are still null keys or incorrect values then it is proved that the problem is in the generation part. Therefore this part of the test will concentrate on the generation of the hash value of the non-leaf node function.

In this test, the generated .bpkg file is used to create the Merkle tree.

If an empty hash value appears when a node is generated, the expected output will output an error message; and here the projected output should be a blank file (the expected blank hash value will appear).

# Test 6 Description - Merkle tree specific node retrieve correctness
In the function return complete chunks, a function with the ability to retrieve all the leaf nodes of the Merkle tree (where the leaf nodes represent the individual data chunks of the pkg) is needed to query the complete chunks. This section will focus on testing the accuracy of the function that queries all leaf nodes of the Merkle tree.

In this test, the example node's key and value is given used to travel the Mekle tree and search node exist or not.

The output will display the expected node values stored inside the Merkle tree.

# Test 7 Description - Extra whitespaces exists in bpkg hash value
In this section I will test that if there is an extra space, the program will exist an error message.

The .bpkg file created by pkgmake with extra whitespace is used here as input.

An error message exists in expected output to demonstrate that an extra whitespace exists in bpkg file.

# Test 8 Description - bpkg format order correctness
This part will be tested that if .bpkg file in the wrong order the program will return an error message.

The .bpkg file created by pkgmake in the wrong order is used here as input.

An error message exists in expected output to demonstrate that a wrong order format exists in bpkg file.

# Test 9 Description - hashes data size correctness in bpkg
With the specification, hashes must be a a [2^(h-1)-1] value and 64 characters for each string. I am testing the hashes data size correctness.

The .bpkg file created by pkgmake with the wrong hashes value size as input in this part.

An error message exists in expected output to demonstrate that the wrong hashes value size exists in bpkg file.

# Test 10 Description - nchunks are consist with number of lines in chunks
In this part is going to test the total number of chunks given in chunks section whether is equal to the number given in nchunks.

The input is given a wrong .bpkg file that nchunks are not consist with number of lines in chunks.

An error message exists in expected output to demonstrate that chunks amount error exists in bpkg file.

# Instruction Reference
data_format_file_generating_method.pdf

# AI Prompt 1
N/A

# AI Generated 1
Original data source:
tests/test01/test1.data

# AI Prompt 2
N/A

# AI Generated 2
Original data source:
tests/test02/test2.data

# AI Prompt 3
N/A

# AI Generated 3
Original data source:
tests/test03/test3.data

# AI Prompt 4
N/A

# AI Generated 4
Original data source:
tests/test04/test4.data

# AI Prompt 5
N/A

# AI Generated 5
Original data source:
tests/test05/test5.data

# AI Prompt 6
N/A

# AI Generated 6
Original data source:
tests/test06/test6.data

# AI Prompt 7
N/A

# AI Generated 7
Original data source:
tests/test07/test7.data

# AI Prompt 8
N/A

# AI Generated 8
Original data source:
tests/test08/test8.data

# AI Prompt 9
N/A

# AI Generated 9
Original data source:
tests/test09/test9.data

# AI Prompt 10
N/A

# AI Generated 10
Original data source:
tests/test10/test10.data

# Instructions to run testing script
Considering the bash file might get perission denied error message, therefore before compiling the bash script should change the file's mode to executable.

The following bash command firstly search all run_test.sh files within the tests, then change file mode and executes the script in the directory where `run_test.sh` file is located.

```bash
find tests -name run_test.sh -exec chmod +x {} \; -execdir ./run_test.sh \;
```
# Instructions Prompt
https://chat.openai.com/share/b022aac7-c855-4281-abfd-65cfdf3c6815

# Instructions Generated
One line bash command to compile all bash script