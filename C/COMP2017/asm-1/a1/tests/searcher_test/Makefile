# gcc command
CC = gcc
CFLAGS = -Wall -Werror -std=c11
TARGET = smallest_triangle
SOURCE = /home/smallest_triangle.c

# path to test script
TEST_SCRIPT = test_script2.sh

searcher:
	@echo "generator make file generate successfully"

# The `all` or `build` rules are "default" rules for Makefiles.
# These will run if you run `make` with no arguments in the same directory as
# the Makefile.
# 
# This rule has a dependency on the value of the `TARGET` variable (our
# program binary).

all: $(TARGET)

	$(CC) $(CFLAGS) -o $(SOURCE) $(TARGET)

test:
	chmod +x $(TEST_SCRIPT)
	./$(TEST_SCRIPT)

clean:
	# clean up generated files
	rm -f /home/tests/searcher_test/*.out