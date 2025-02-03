# python type command
PYTHON = python3

# program path
PROGRAM = /home/gen_points.py

# path to test script
TEST_SCRIPT = test_script1.sh

# NOOP in generator
generator:
	@echo "generator make file generate successfully"
	@echo "No operation rule required for Python script"

# to run main python program
run:
	$(PYTHON) $(PROGRAM)

# to run tesst script
test:
	chmod +x $(TEST_SCRIPT)
	./$(TEST_SCRIPT)

clean:
	# clean up files
	rm -f /home/tests/generator_test/*.out