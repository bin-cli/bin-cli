prefix      ?= /usr/local
exec_prefix ?= $(prefix)
bindir      ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
docdir      ?= $(datarootdir)/doc/bin-cli
htmldir     ?= $(docdir)
mandir      ?= $(datarootdir)/man
man1dir     ?= $(mandir)/man1
man5dir     ?= $(mandir)/man5

version := $(file < VERSION)

# Default target - build files we need in the package, but not pages for the website
.PHONY: all
all: bin completion man readme-html

# Build the application itself
.PHONY: bin
bin: temp/dist/bin

temp/dist/bin: src/bin bin/build VERSION
	bin/build "$(version)"

# Build the bash-completion script
.PHONY: completion
completion: temp/dist/bin.bash-completion

temp/dist/bin.bash-completion: temp/dist/bin
	"$<" --completion > "$@"

# Build the man pages
.PHONY: man
man: $(patsubst src/%.md,temp/dist/%.gz,$(wildcard src/*.md))

temp/dist/%.gz: src/%.md bin/generate/man VERSION
	bin/generate/man "$*" "$(version)"

# Build the HTML version of the man pages
.PHONY: man-html
man-html: $(patsubst src/%.md,temp/dist/%.html,$(wildcard src/*.md)) temp/dist/pandoc-man.css

temp/dist/%.html: src/%.md bin/generate/man VERSION
	bin/generate/man --html "$*" "$(version)"

temp/dist/pandoc-man.css: src/pandoc-man.css
	mkdir -p temp/dist
	cp "$<" "$@"

# Update the README
.PHONY: readme
readme: README.md

README.md: $(wildcard features/*.feature) $(wildcard features/*.md) bin/generate/readme
	bin/generate/readme

# Convert the README to HTML
.PHONY: readme-html
readme-html: temp/dist/readme.html temp/dist/pandoc-readme.css

temp/dist/pandoc-readme.css: src/pandoc-readme.css
	mkdir -p temp/dist
	cp "$<" "$@"

temp/dist/readme.html: README.md temp/dist/pandoc-readme.css
	bin/generate/readme-html

# Generate HTML readme and man pages for the website
.PHONY: html
html: man-html readme-html

# Install the files that were previously built
.PHONY: install
install:
	install -Dm 0755 temp/dist/bin "$(DESTDIR)$(bindir)/bin"
	install -Dm 0644 temp/dist/bin.bash-completion "$(DESTDIR)$(datarootdir)/bash-completion/completions/bin"
	install -Dm 0644 temp/dist/bin.1.gz "$(DESTDIR)$(man1dir)/bin.1.gz"
	install -Dm 0644 temp/dist/binconfig.5.gz "$(DESTDIR)$(man5dir)/binconfig.5.gz"
	install -Dm 0644 temp/dist/pandoc-readme.css "$(DESTDIR)$(htmldir)/pandoc-readme.css"
	install -Dm 0644 temp/dist/readme.html "$(DESTDIR)$(htmldir)/index.html"

# Clean up all generated files
.PHONY: clean
clean:
# Delete node_modules/ as well to ensure it isn't included in the package source (debuild -sa)
# Ideally I would delete/ignore the .idea/ directory as well, but I need that
# It doesn't matter too much though since the production build happen in CI/CD
	rm -rf temp node_modules
