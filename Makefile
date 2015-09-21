# Copyright (C) 2012-2014 Simon Josefsson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

VERSION=1.0

DESTDIR?=
prefix=/usr
bindir=${prefix}/bin
etcdir=/etc
sharedir=$(prefix)/share
mandir=${prefix}/share/man

INSTALL=install
INSTALL_EXE=$(INSTALL) -D --mode 755
INSTALL_DATA=$(INSTALL) -D --mode 0644
PRG_DIR=gencrl.d gentoken.d help.d init.d issue.d lib publish.d root.d revoke.d
DATA_DIR=public_html

PRG=$$(find $(PRG_DIR) -type f -o -type l)
DATA=$$(find $(DATA_DIR) -type f)

all: manpages

CMDHELPS=$(wildcard *.d/help)
CMDPAGES=$(patsubst %.d/help, ici-%.1, $(CMDHELPS))
manpages: ici.1 ici_req.1 $(CMDPAGES)
ici.1: ici Makefile
	ICI_CONF_DIR=util help2man --name="Imbecil Certificate Issuer" \
		--no-info --no-discard-stderr --output=$@ ./$<
ici_req.1: ici_req Makefile
	ICI_CONF_DIR=util help2man --name="Imbecil Certificate Issuer" \
		--no-info --no-discard-stderr --output=$@ ./$<
$(CMDPAGES): ici Makefile $(CMDHELPS)
	ICI_CONF_DIR=util help2man --name="Imbecil Certificate Issuer" \
		--no-info --no-discard-stderr \
		--help-option="help `echo $@ | cut -f2 -d- | cut -f1 -d.`" \
		--output=$@ ./$<

install: all
	$(INSTALL_DATA) --backup --suffix .old ici.conf $(DESTDIR)$(etcdir)/ici/ici.conf.dist
	[ -f $(DESTDIR)$(etcdir)/ici/ici.conf ] || \
		$(INSTALL_DATA) ici.conf $(DESTDIR)$(etcdir)/ici/ici.conf
	$(INSTALL_EXE) ici $(DESTDIR)$(bindir)/ici
	for f in ici.1 ici_req.1 $(CMDPAGES); do \
		$(INSTALL) -D $$f $(DESTDIR)$(mandir)/man1/$$f; \
	done
	for f in $(PRG); do \
		$(INSTALL_EXE) $$f $(DESTDIR)$(sharedir)/ici/$$f; \
	done
	for f in $(DATA); do \
		$(INSTALL) -D $$f $(DESTDIR)/$(sharedir)/ici/$$f; \
	done
	cp -pr public_html $(DESTDIR)/$(sharedir)/ici/public_html
	@[ -f $(DESTDIR)$(etcdir)/ici/ici.conf.dist.old ] && \
	cmp -s $(DESTDIR)$(etcdir)/ici/ici.conf.dist $(DESTDIR)$(etcdir)/ici/ici.conf.dist.old || \
		{ echo "*****"; \
		  echo "***** Distribution configuration has changed, you may need to edit"; \
		  echo "***** $(DESTDIR)$(etcdir)/ici/ici.conf accordingly"; \
		  echo "*****"; }

clean:

distclean:

maintainerclean:
	rm -f ici.1 $(CMDPAGES)

check:
	@echo "no checks implemented - if it compiles, ship it!"

dist: all
	rm -rf ici-$(VERSION)
	mkdir ici-$(VERSION)
	cp -r COPYING AUTHORS NEWS Makefile README ici ici.1 $(CMDPAGES) $(PRG_DIR) $(DATA_DIR) ici-$(VERSION)/
	tar cfz ici-$(VERSION).tar.gz ici-$(VERSION)
	rm -rf ici-$(VERSION)

distcheck: dist
	rm -rf ici-$(VERSION)
	tar xfz ici-$(VERSION).tar.gz
	make -C ici-$(VERSION) install DESTDIR=ff
	make -C ici-$(VERSION) check
	rm -rf ici-$(VERSION)

release: distcheck
	head -1 NEWS | grep "^Version $(VERSION) released"
	gpg --detach-sign ici-$(VERSION).tar.gz
	gpg --verify ici-$(VERSION).tar.gz.sig
	cp ici-$(VERSION).tar.gz ici-$(VERSION).tar.gz.sig ../releases/ici/
