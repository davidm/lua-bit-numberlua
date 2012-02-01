#!/usr/bin/make -f
# utility commands for package maintainers
# D.Manura, This util.mk file is public domain.

VERSIONFROM:=$(shell sed -n 's,.*VERSIONFROM *= *[\"]\(.*\)[\"],\1,p' rockspec.in)
ROCKVERSION:=$(shell sed -n 's,.*ROCKVERSION *= *[\"]\(.*\)[\"],\1,p' rockspec.in)
ROCKSCMVERSION:=$(shell sed -n 's,.*ROCKSCMVERSION *= *[\"]\(.*\)[\"],\1,p' rockspec.in)
VERSION:=$(shell sed -n "s,.*_VERSION='\([^']*\)'.*,\1,p" $(VERSIONFROM))
SCMVERSION:=scm
NAME:=$(shell sed -n 's,.*package *= *[\"]\(.*\)[\"],\1,p' rockspec.in)
#NAME=$(shell lua -e 'dofile"rockspec.in"; print(package)')

dist : version
	rm -fr tmp/
	for x in `cat MANIFEST`; do install -D $$x tmp/$(NAME)-$(VERSION)-$(ROCKVERSION)/$$x || exit; done
	cat rockspec.in | \
	  sed 's,$$(_VERSION),$(VERSION),g' | \
	  sed 's,$$(ROCKVERSION),$(ROCKVERSION),g' | \
	  sed 's,^--URL=,  url=,' >  tmp/$(NAME)-$(VERSION)-$(ROCKVERSION).rockspec
	cat rockspec.in | \
	  sed 's,$$(_VERSION),$(SCMVERSION),g' | \
	  sed 's,$$(ROCKVERSION),$(ROCKSCMVERSION),g' | \
	  sed 's,^--URLSCM=,  url=,' | \
	  sed '/tag *= */d' > tmp/$(NAME)-$(SCMVERSION)-$(ROCKSCMVERSION).rockspec
	cp tmp/$(NAME)-$(VERSION)-$(ROCKVERSION).rockspec tmp/$(NAME)-$(VERSION)-$(ROCKVERSION)/
	cp tmp/$(NAME)-$(SCMVERSION)-$(ROCKSCMVERSION).rockspec tmp/$(NAME)-$(VERSION)-$(ROCKVERSION)/
	cd tmp && zip -r $(NAME)-$(VERSION)-$(ROCKVERSION).zip $(NAME)-$(VERSION)-$(ROCKVERSION)

install : dist
	cd tmp/$(NAME)-$(VERSION)-$(ROCKVERSION) && luarocks make

test :
	@if [ -e test.lua ]; then lua test.lua; fi
	@if [ -e test/test.lua ]; then lua test/test.lua; fi

tag :
	git tag -f v$(VERSION)-$(ROCKVERSION)

version :
	@echo $(NAME)-$(VERSION)-$(ROCKVERSION)
	@echo $(NAME)-$(SCMVERSION)-$(ROCKSCMVERSION)

.PHONY : dist install test tag version
