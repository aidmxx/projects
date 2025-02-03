#!/bin/bash

# auto-running test for generator
cd /home/tests/generator_test
make || { echo "make failed in generator test"; exit 1; }
make test || { echo "make test failed in generator test"; exit 1; }

echo "-----------------------"

# auto-running test for searcher
cd /home/tests/searcher_test
make || { echo "make failed in searcher test"; exit 1; }
make test || { echo "make test failed in searcher test"; exit 1; }

echo "-----------------------"

# auto-running test for E2E
cd /home/tests/E2E_test
make || { echo "make failed in E2E test"; exit 1; }
make test || { echo "make test failed in E2E test"; exit 1; }

echo "-----------------------"

echo "All tests completed successfully."