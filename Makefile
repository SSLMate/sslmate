#
# Copyright (c) 2014-2015 Opsmate, Inc.
#
# See COPYING file for license information.
#

PROJECT = sslmate
VERSION = 0.7.0-pre5

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
DOCDIR ?= $(PREFIX)/share/doc/sslmate
MANDIR ?= $(PREFIX)/share/man
LIBEXECDIR ?= $(PREFIX)/libexec/sslmate
DISTDIR ?= $(PROJECT)-$(VERSION)
DISTFILE ?= $(DISTDIR).tar

all: build

#
# Build
#
build: build-bin build-man

build-bin: bin/sslmate.bin

build-man:
#	$(MAKE) -C man all

bin/sslmate.bin: bin/sslmate
	sed "s|DEFAULT_LIBEXEC_DIR = undef|DEFAULT_LIBEXEC_DIR = '$(LIBEXECDIR)'|" < $< > $@

#
# Clean
#
clean: clean-bin clean-man

clean-bin:
	rm -f bin/sslmate.bin

clean-man:
#	$(MAKE) -C man clean

#
# Install
#
install: install-bin install-doc install-man install-libexec

install-bin: bin/sslmate.bin
	mkdir -m 755 -p $(DESTDIR)$(BINDIR)
	install -m 755 bin/sslmate.bin $(DESTDIR)$(BINDIR)/sslmate

install-doc:
	mkdir -m 755 -p $(DESTDIR)$(DOCDIR)
	install -m 644 README NEWS $(DESTDIR)$(DOCDIR)/

install-man:
	mkdir -m 755 -p $(DESTDIR)$(MANDIR)/man1
	install -m 644 man/man1/sslmate.1 $(DESTDIR)$(MANDIR)/man1/

install-libexec:
	mkdir -m 755 -p $(DESTDIR)$(LIBEXECDIR)/approval/http
	mkdir -m 755 -p $(DESTDIR)$(LIBEXECDIR)/approval/dns
	install -m 755 libexec/sslmate/approval/http/documentroot $(DESTDIR)$(LIBEXECDIR)/approval/http/documentroot
	install -m 755 libexec/sslmate/approval/dns/route53 $(DESTDIR)$(LIBEXECDIR)/approval/dns/route53

install-paths:
	mkdir -m 755 -p $(DESTDIR)/etc/paths.d $(DESTDIR)/etc/manpaths.d
	echo $(BINDIR) > $(DESTDIR)/etc/paths.d/sslmate
	echo $(MANDIR) > $(DESTDIR)/etc/manpaths.d/sslmate

#
# Uninstall
#
uninstall: uninstall-bin uninstall-doc uninstall-man uninstall-libexec

uninstall-bin:
	rm -f $(DESTDIR)$(BINDIR)/sslmate

uninstall-doc:
	rm -f $(DESTDIR)$(DOCDIR)/README
	rm -f $(DESTDIR)$(DOCDIR)/NEWS
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(DOCDIR)

uninstall-man:
	rm -f $(DESTDIR)$(MANDIR)/man1/sslmate.1

uninstall-libexec:
	rm -f $(DESTDIR)$(LIBEXECDIR)/approval/http/documentroot
	rm -f $(DESTDIR)$(LIBEXECDIR)/approval/dns/route53
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(LIBEXECDIR)/approval/http
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(LIBEXECDIR)/approval/dns
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(LIBEXECDIR)/approval
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(LIBEXECDIR)

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
	install install-bin install-man install-libexec install-paths \
	uninstall uninstall-bin uninstall-man uninstall-libexec uninstall-paths \
	dist get-version
