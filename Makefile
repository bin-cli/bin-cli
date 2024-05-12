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
	install -m 0755 -d "$(DESTDIR)$(bindir)"
	install -m 0755 temp/dist/bin "$(DESTDIR)$(bindir)"
	install -m 0755 -d "$(DESTDIR)$(man1dir)"
	install -m 0644 temp/dist/bin.1.gz "$(DESTDIR)$(man1dir)"
	install -m 0755 -d "$(DESTDIR)$(man3dir)"
	install -m 0644 temp/dist/binconfig.5.gz "$(DESTDIR)$(man5dir)"

.PHONY: build install
