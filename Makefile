prefix      ?= /usr/local
exec_prefix ?= $(prefix)
bindir      ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
mandir      ?= $(datarootdir)/man
man1dir     ?= $(mandir)/man1
man5dir     ?= $(mandir)/man5

build:
ifndef VERSION
	$(error VERSION is undefined)
endif
	rm -rf temp/dist
	bin/build "$(VERSION)"
	bin/generate/man "$(VERSION)"
	gzip temp/dist/bin.1 temp/dist/binconfig.5

install:
	install -Dm 0755 temp/dist/bin "$(DESTDIR)$(bindir)/bin"
	install -Dm 0644 temp/dist/bin.1.gz "$(DESTDIR)$(man1dir)/bin.1.gz"
	install -Dm 0644 temp/dist/binconfig.5.gz "$(DESTDIR)$(man5dir)/binconfig.5.gz"

clean:
	rm -rf node_modules temp

.PHONY: build install
