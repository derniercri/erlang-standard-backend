# Constants
EBIN    = ebin
SRC     = src
JeSON   = $(SRC)/JeSON
INCLUDE = include
COMPILE = erlc -I $(INCLUDE) -pa $(EBIN) -o $(EBIN)
LIB     = uri.beam return.beam crypter.beam html.beam
DEPS    = init JeSON $(LIB) route.beam 

# Phony rule
.PHONY: all clean

# Initialization
init:
	mkdir -p $(EBIN)
	mkdir -p assets
	mkdir -p log

# Generic rules
%.beam: src/%.erl
	$(COMPILE) $(<)

# Build lib
JeSON: init
	$(COMPILE) $(JeSON)/coers.erl
	$(COMPILE) $(JeSON)/json_encoder.erl
	$(COMPILE) $(JeSON)/json_decoder.erl
	$(COMPILE) $(JeSON)/jeson.erl

# General flow
all: $(DEPS)
run: all
	yaws --conf yaws.conf

run-daemon: all
	yaws --conf yaws.conf --daemon --heart

stop-daemon:
	yaws --daemon --stop

# Clean rules
clean: clean_binaries clean_tempfiles clean_log
clean_binaries:
	rm -rf ebin/
clean_tempfiles:
	rm -rf *~
	rm -rf */*~
	rm -rf */*/*~	
	rm -rf \#*\#
	rm -rf */\#*\#
	rm -rf */*/\#*\#
clean_log:
	rm -rf log/*
