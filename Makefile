init:
	@echo You probably want to run "zig build" instead.
.PHONY: init

setup:
	brew install zig gettext
	xcodebuild -downloadComponent MetalToolchain
	sudo xcode-select --switch /Applications/Xcode.app
	@echo "Setup complete. Run 'zig build' to build Ghostty."
.PHONY: setup

run:
	zig build run -Doptimize=ReleaseFast
.PHONY: run

install:
	zig build -Doptimize=ReleaseFast
	cp -r zig-out/Ghostty.app /Applications/Ghostty.app
.PHONY: install

VERSION := $(shell grep '\.version = ' build.zig.zon | head -1 | sed 's/.*"\(.*\)".*/v\1/')
release:
	gh release create $(VERSION) --title "$(VERSION)" --generate-notes
.PHONY: release
# glad updates the GLAD loader. To use this, place the generated glad.zip
# in this directory next to the Makefile, remove vendor/glad and run this target.
#
# Generator: https://gen.glad.sh/
glad: vendor/glad
.PHONY: glad

vendor/glad: vendor/glad/include/glad/gl.h vendor/glad/include/glad/glad.h

vendor/glad/include/glad/gl.h: glad.zip
	rm -rf vendor/glad
	mkdir -p vendor/glad
	unzip glad.zip -dvendor/glad
	find vendor/glad -type f -exec touch '{}' +

vendor/glad/include/glad/glad.h: vendor/glad/include/glad/gl.h
	@echo "#include <glad/gl.h>" > $@

clean:
	rm -rf \
		zig-out .zig-cache \
		macos/build \
		macos/GhosttyKit.xcframework
.PHONY: clean
