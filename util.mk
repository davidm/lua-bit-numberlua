# utility commands for package maintainers

VERSION:=$(shell grep -P -o "(?<=_VERSION=')[^']*(?=')" lmod/bit/numberlua.lua)-1
NAME=lua-bit-numberlua

dist :
	rm -fr tmp/$(NAME)-$(VERSION) tmp/$(NAME)-$(VERSION).zip
	for x in `cat MANIFEST`; do install -D $$x tmp/$(NAME)-$(VERSION)/$$x; done
	sed 's,$$(_VERSION),$(VERSION),g' tmp/$(NAME)-$(VERSION)/$(NAME).rockspec > tmp/$(NAME)-$(VERSION)/$(NAME)-$(VERSION).rockspec
	cd tmp && zip -r $(NAME)-$(VERSION).zip $(NAME)-$(VERSION)

tag :
	git tag -f v$(VERSION)

version :
	@echo $(NAME)-$(VERSION)
