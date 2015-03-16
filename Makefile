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
mandir=${prefix}/share/man

INSTALL=install
INSTALL_EXE=$(INSTALL) -D --mode 755
INSTALL_DATA=$(INSTALL) -D --mode 0644
PRG_DIR=gencrl.d gentoken.d init.d issue.d lib publish.d root.d
DATA_DIR=public_html

PRG=$(find $(PRG_DIR) -type f)

all: ici.1

ici.1: Makefile ici
	help2man --name="Imbecil Certificate Issuer" \
		--no-info --no-discard-stderr --output=$@ ./ici

install: all
	$(INSTALL) -D --backup --mode 640 ici.conf $(DESTDIR)$(etcdir)/ici/ici.conf
	$(INSTALL_EXE) ici $(DESTDIR)$(bindir)/ici
	$(INSTALL) -D ici.1 $(DESTDIR)$(mandir)/man1/ici.1
	for f in $(PRG_DIR); do \
		$(INSTALL_EXE) $$f $(DESTDIR)$(etcdir)/ici/$$f; \
	done

clean:

distclean:

maintainerclean:
	rm -f ici.1

check:
	@echo "no checks implemented - if it compiles, ship it!"

dist: all
	rm -rf ici-$(VERSION)
	mkdir ici-$(VERSION)
	cp -r COPYING AUTHORS NEWS Makefile README ici ici.1 $(PRG_DIR) $(DATA_DIR) ici-$(VERSION)/
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
