# software structure
This task is to build a P2P programme that can send, receive and detect anomalous blocks of data. And this task is divided into two parts.

# P1
The first part loads and performs a series of detections on data blocks by building a Merkle tree. The first part is to build a Merkle tree to load and detect the data chunks by constructing a series of detections, which are divided into four main detections: getting all hashes, all valid chunk hashes, the least valid chunk hashes and finding all the child hashes according to the provided parent hashes, where the Merkle tree will be constructed according to the provided .bpkg file in the level order to ensure that there is a correlation between the nodes. to ensure that the nodes are related to each other and can be found quickly. And this program has achieved all the building as the pervious mentioned.

# P2
The second part of the project is divided into loading configuration files for compilation, the connection to peers, and package management. The executable performs different functions according to the commands provided. This programme implements the functions of connecting and disconnecting the specified IP and port devices (CONNECT), as well as managing, adding and deleting software packages (PACKAGES). However, it does not implement the part of requesting data blocks (FETCH).

# Testing
All .bpkg file in testcases are compiled by using pkgmake binary file. The following command given on Ed workspace shows how to generate a .data file and then generate a .bpkg file based on that .data file.
To generate a data file:
HOWLONG=512 # bytes
FILENAME=data
cat /dev/urandom | head -c $HOWLONG > $FILENAME
xxd $FILENAME

To generate a bpkg file:
./pkgmake < .data file path > --nchunks <number> --output <bpkg filename>.bpkg

# P1 test
This part will be modified and tested according to the relevant Merkle tree mentioned in the A3 testing. 

- Test 1: Computed non-leaf node hash value correctness
    This part of the test looks up the hash values of all non-leaf nodes (all values stored in 'hashes:'). Considering the structure of pkgmain, the flag -all_hashes will be executed and only the values of the full number of nhashes (counted from the beginning to the end) will be kept for comparison with the expected output.

- Test 2: Computed hashes in right size and correct value
    This section tests the length and accuracy of the Merkle tree in comparing the sha256 computed hashes with the values of the original file. And the test will select one of the valid hash values and length to compare with the actual output.

- Test 3: Merkle tree root hash value character correctness
    This part tests the length and accuracy of the root of the Merkle tree against the value of the original file (the first value in 'hashes:' is the root of the Merkle tree).

- Test 4: Empty nodes hashes exists
    This section will assume that if there are blank nodes or unfinished nodes in the Merkle tree. So this section will use the -chunk_check flag to return all the completed chunk hashes and compare them with the expected output.

- Test 5: Merkle tree specific node retrieve correctness
    This section tests the build completeness and queryability of the Merkle tree. The test will use -hashes_of and provide a valid non-leaf node, run the program to return all of its children and compare it to the expected output.

# P2 test
This part of tests are all negative tests for package list and connection.

- Test 1: List all stored packages
    This section tests the status of loaded package. As the negetive tests, there was no packages loaded therefore an error message stdout exists.

- Test 2: Try to connect with given ip and port
    This section tests that attempts to connect a peer with the network. As an invalid ip and port given, the connection will failed and print error message stdout.
