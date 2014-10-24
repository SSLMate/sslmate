#
# Copyright (c) 2014 Opsmate, Inc.
#
# See COPYING file for license information.
#

PROJECT = sslmate
VERSION = 0.4.2

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
DOCDIR ?= $(PREFIX)/share/doc/sslmate
MANDIR ?= $(PREFIX)/share/man
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
install: install-bin install-doc install-man

install-bin:
	mkdir -m 755 -p $(DESTDIR)$(BINDIR)
	install -m 755 bin/sslmate $(DESTDIR)$(BINDIR)/

install-doc:
	mkdir -m 755 -p $(DESTDIR)$(DOCDIR)
	install -m 644 README NEWS $(DESTDIR)$(DOCDIR)/

install-man:
	mkdir -m 755 -p $(DESTDIR)$(MANDIR)/man1
	install -m 644 man/man1/sslmate.1 $(DESTDIR)$(MANDIR)/man1/

install-paths:
	mkdir -m 755 -p $(DESTDIR)/etc/paths.d $(DESTDIR)/etc/manpaths.d
	echo $(BINDIR) > $(DESTDIR)/etc/paths.d/sslmate
	echo $(MANDIR) > $(DESTDIR)/etc/manpaths.d/sslmate

#
# Uninstall
#
uninstall: uninstall-bin uninstall-doc uninstall-man

uninstall-bin:
	rm -f $(DESTDIR)$(BINDIR)/sslmate

uninstall-doc:
	rm -f $(DESTDIR)$(DOCDIR)/README
	rm -f $(DESTDIR)$(DOCDIR)/NEWS
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(DOCDIR)

uninstall-man:
	rm -f $(DESTDIR)$(MANDIR)/man1/sslmate.1

uninstall-paths:
	rm -f $(DESTDIR)/etc/paths.d/sslmate $(DESTDIR)/etc/manpaths.d/sslmate

#
# 'make dist'
#
dist:
	git archive --prefix=$(DISTDIR)/ $(VERSION) | gzip -n9 > $(DISTFILE).gz

#
# Misc.
#
get-version:
	@echo $(VERSION)

.PHONY: all \
	build build-bin build-man \
	clean clean-bin clean-man \
	install install-bin install-man \
	uninstall uninstall-bin uninstall-man \
	dist get-version
