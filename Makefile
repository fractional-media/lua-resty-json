#################################################################
#
#      Binaries we are going to build, and its source code
#
#################################################################
#
OS := $(shell uname)

SRC := mempool.c scaner.c parse_array.c parse_hashtab.c parser.c scan_fp_strict.c scan_fp_relax.c
OBJ := $(SRC:.c=.o)

DEMO := demo

ifeq ($(OS), Darwin)
C_SO_NAME := libljson.so
INSTALL_FLAG := 
else
C_SO_NAME := libljson.so
INSTALL_FLAG := "-D"
endif

#################################################################
#
#       Compile and link flags
#
#################################################################
#
CFLAGS := -Wall -O3 -flto -g -DFP_RELAX=0 #-DDEBUG
THE_CFLAGS := $(CFLAGS)  -MMD -fvisibility=hidden -fPIC
ifeq ($(OS), Linux)
    THE_CFLAGS := $(THE_CFLAGS) -Wl,--build-id
endif

#################################################################
#
#       Installtion flags
#
#################################################################
#

LUA_VERSION = 5.1

PREFIX := /usr/local
SO_TARGET_DIR := $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_TARGET_DIR := $(PREFIX)/share/lua/$(LUA_VERSION)/

#################################################################
#
#       Make recipes
#
#################################################################
#
.PHONY = all test clean install

all : $(C_SO_NAME) $(DEMO)

-include dep.txt

${OBJ} : %.o : %.c
	$(CC) $(THE_CFLAGS) -DBUILDING_SO -c $<

${C_SO_NAME} : ${OBJ}
	$(CC) $(THE_CFLAGS) -DBUILDING_SO $^ -shared -o $@
	cat *.d > dep.txt

demo : ${C_SO_NAME} demo.o
	$(CC) $(THE_CFLAGS) -Wl,-rpath,. demo.o -L. -lljson -o $@

test :
	$(MAKE) -C tests

clean:; rm -f *.o *.so a.out *.d dep.txt demo

install:
	install $(INSTALL_FLAG) -m 755 $(C_SO_NAME) $(SO_TARGET_DIR)/$(C_SO_NAME)
	install $(INSTALL_FLAG) -m 666 json_decoder.lua  $(LUA_TARGET_DIR)/json_decoder.lua
