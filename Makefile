.PHONY: all build run install clean

all: build

build:
	@./build.sh

run: build
	@open MenuBarCalendar.app

install: build
	@./install.sh

clean:
	@rm -rf MenuBarCalendar.app
	@echo "Cleaned build artifacts."
