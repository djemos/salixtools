PREFIX ?= /usr/local
DESTDIR ?= /
PACKAGE_LOCALE_DIR ?= /usr/share/locale
TOOLS = clocksetup keyboardsetup localesetup usersetup servicesetup service reposetup
ALL_TOOLS = $(TOOLS) update-all


all: man mo

mo:
	for i in $(TOOLS); do \
		for j in `ls $$i/po/*.po`;do \
			echo "Compiling `echo $$j|sed "s|/po||"`"; \
			msgfmt $$j -o `echo $$j | sed "s/\.po//"`.mo; \
		done; \
	done

man:
	for i in $(ALL_TOOLS); do \
		( \
		cd $$i/man; \
		echo "Compiling $$i manpage"; \
		txt2tags *.t2t || exit 1; \
		mv $$i.man $$i.8; \
		); \
	done

clean:
	rm -f */po/*.mo
	rm -f */po/*.po~
	rm -f */man/*.man
	rm -f */man/*.8

install:
	install -d -m 755 $(DESTDIR)/usr/sbin
	install -d -m 755 $(DESTDIR)/usr/share/salixtools/servicesetup
	install -d -m 755 $(DESTDIR)/usr/share/salixtools/keyboardsetup
	install -d -m 755 $(DESTDIR)/usr/share/salixtools/reposetup
	install -d -m 755 $(DESTDIR)/etc/rc.d/desc.d
	for i in $(TOOLS); do \
		install -m 755 $$i/$$i $(DESTDIR)/usr/sbin/; \
		for j in `ls $$i/po/*.mo`; do \
			install -d -m 755 \
			$(DESTDIR)/$(PACKAGE_LOCALE_DIR)/`basename $$j|sed "s/.mo//"`/LC_MESSAGES \
			2> /dev/null; \
			install -m 644 $$j \
			$(DESTDIR)/$(PACKAGE_LOCALE_DIR)/`basename $$j|sed "s/.mo//"`/LC_MESSAGES/$$i.mo; \
		done; \
	done
	install -m 755 update-all/update-all $(DESTDIR)/usr/sbin/
	install -d -m 755 $(DESTDIR)/usr/man/man8
	for i in $(ALL_TOOLS); do \
		( \
		cd $$i/man; \
		for j in `ls *.8`; do \
			install -m644 $$j $(DESTDIR)/usr/man/man8/; \
		done \
		);\
	done
	install -m 644 keyboardsetup/keymaps $(DESTDIR)/usr/share/salixtools/
	install -m 644 keyboardsetup/10-keymap.conf-template $(DESTDIR)/usr/share/salixtools/keyboardsetup
	install -m 755 keyboardsetup/rc.numlock $(DESTDIR)/etc/rc.d/
	install -m 644 service/service-blacklist $(DESTDIR)/usr/share/salixtools/servicesetup/
	install -m 644 service/shell-colours $(DESTDIR)/usr/share/salixtools/servicesetup/
	install -m 644 service/standard.txt $(DESTDIR)/etc/rc.d/desc.d/
	install -m 644 reposetup/repomirrors $(DESTDIR)/usr/share/salixtools/reposetup
	install -m 644 salix-version $(DESTDIR)/usr/share/salixtools/

update-po:
	for i in $(TOOLS); do \
		cd $$i; \
		echo "Creating $$i.pot file..."; \
		xgettext --from-code=utf-8 -L shell -o po/$$i.pot $$i; \
		cd po; \
		for j in `ls *.po`; do \
			echo -n "Merging $$j translation for $$i..."; \
			msgmerge -U $$j $$i.pot; \
		done; \
		rm -f ./*~; \
		cd ../../; \
	done

tx-pull:
	for i in $(TOOLS); do \
		cd $$i; \
		tx pull -a; \
		for j in `ls po/*.po`; do \
			msgfmt --statistics $$j 2>&1 | grep "^0 translated" > /dev/null \
			&& rm $$j || true; \
			rm -f messages.mo; \
		done; \
		cd ..; \
	done

stat:
	@for i in $(TOOLS); do \
		cd $$i; \
		echo "=================="; \
		echo "$$i"; \
		echo "=================="; \
		for j in `ls po/*.po`; do \
			echo "Statistics for $$j:"; \
			msgfmt --statistics $$j 2>&1; \
			echo; \
		done; \
		cd ..; \
	done


.PHONY: all man mo update-po tx-pull clean install stat
