LUA = $(wildcard *.lua)
SRC = $(wildcard *.fnl)
OUT = $(patsubst %.fnl,%.lua,$(SRC))

all: $(OUT)
	echo "Done"

%.lua: %.fnl; fennel --compile --correlate $< > $@
