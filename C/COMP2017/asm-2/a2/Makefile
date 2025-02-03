CC=gcc
FLAGS=-Wall -Werror -g
OBJS=mtll.o main.o
TARGET=mtll

build: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(FLAGS) $^ -o $@

%.o: %.c
	$(CC) -c $(FLAGS) $< -o $@

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(TARGET)