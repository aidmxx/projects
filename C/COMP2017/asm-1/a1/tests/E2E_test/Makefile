# python type command
PYTHON = python3
GENERATOR = /Users/y2l/a1/gen_points.py
SEARCHER = smallest_triangle
CC = gcc
CFLAGS = -Wall -Werror -std=c11
SOURCE = /home/smallest_triangle.c

# path to test script
TEST_SCRIPT = test_script3.sh

E2E:
	@echo "E2E test file generated successfully"

all:
	$(CC) $(CFLAGS) -o $(SEARCHER) $(SOURCE)

run:
	$(PYTHON) $(GENERATOR) | ./$(SEARCHER)

# to run tesst script
test:
	chmod +x $(TEST_SCRIPT)
	./$(TEST_SCRIPT)

clean:
	# clean up generated files
	rm -f /home/tests/E2E_test/*.out