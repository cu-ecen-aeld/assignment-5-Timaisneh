# Compiler and flags
CC = gcc
CROSS_COMPILE ?= 
CFLAGS = -Wall -Wextra -pedantic -std=c99

# Source files and executable name
SRC = writer.c
EXE = writer

# Default target
all: $(EXE)

# Build the writer application
$(EXE): $(SRC)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $^

# Clean target
clean:
	rm -f $(EXE) *.o

.PHONY: all clean

