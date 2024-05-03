CC ?= gcc
CFLAGS = -Wall

TARGET = aesdsocket
SRC = aesdsocket.c
OBJ = $(SRC:.c=.o)

all: default

default: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJ)

.PHONY: all default clean

