DESTDIR ?= /
PACKAGE_LOCALE_DIR ?= /usr/share/locale

export DESTDIR PACKAGE_LOCALE_DIR

.PHONY: all
all: man mo

.PHONY: mo
mo:
	$(MAKE) -C po

.PHONY: man
man:
	$(MAKE) -C man

.PHONY: clean
clean:
	$(MAKE) clean -C po
	$(MAKE) clean -C man

.PHONY: install
install:
	install -d -m 755 $(DESTDIR)/usr/sbin
	install -m 755 clocksetup $(DESTDIR)/usr/sbin/
	$(MAKE) install -C po
	$(MAKE) install -C man

.PHONY: pot
pot:
	xgettext --from-code=utf-8 -L shell -o po/clocksetup.pot clocksetup

.PHONY: update-po
update-po:
	$(MAKE) update-po -C po

.PHONY: tx-pull
tx-pull:
	tx pull -a
	$(MAKE) remove-empty -C po

.PHONY: stat
stat:
	$(MAKE) stat -C po

