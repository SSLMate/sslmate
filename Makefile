PROJECT = sslmate
VERSION = 0.4.0

PREFIX ?= /usr/local
MANDIR ?= $(PREFIX)/share/man
BINDIR ?= $(PREFIX)/bin
DISTDIR ?= $(PROJECT)-$(VERSION)
DISTFILE ?= $(DISTDIR).tar

all: build

#
# Build
#
build: build-bin build-man

build-bin:

build-man:
#	$(MAKE) -C man all

#
# Clean
#
clean: clean-bin clean-man

clean-bin:

clean-man:
#	$(MAKE) -C man clean

#
# Install
#
install: install-bin install-man

install-bin:
	mkdir -m 755 -p $(DESTDIR)$(BINDIR)
	install -m 755 bin/sslmate $(DESTDIR)$(BINDIR)/

install-man:
	mkdir -m 755 -p $(DESTDIR)$(MANDIR)/man1
	install -m 644 man/man1/sslmate.1 $(DESTDIR)$(MANDIR)/man1/

#
# Uninstall
#
uninstall: uninstall-bin uninstall-man

uninstall-bin:
	rm -f $(DESTDIR)$(BINDIR)/sslmate

uninstall-man:
	rm -f $(DESTDIR)$(MANDIR)/man1/sslmate.1

#
# 'make dist'
#
dist:
	git archive --prefix=$(DISTDIR)/ $(VERSION) | gzip -n9 > $(DISTFILE).gz

.PHONY: all \
	build build-bin build-man \
	clean clean-bin clean-man \
	install install-bin install-man \
	uninstall uninstall-bin uninstall-man \
	dist
