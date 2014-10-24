#
# Copyright (c) 2014 Opsmate, Inc.
#
# See COPYING file for license information.
#

MANPAGES = man1/sslmate.1
DOCBOOK = xsltproc \
	--param man.output.in.separate.dir 1 \
	--stringparam man.output.base.dir "" \
	--param man.output.subdirs.enabled 1 \
	--param man.authors.section.enabled 0 \
	/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl

all: $(MANPAGES)

man1/sslmate.1: sslmate.xml
	$(DOCBOOK) $<

clean:
	rm -f $(MANPAGES)

.PHONY: all clean
