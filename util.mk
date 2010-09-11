# utility commands for package maintainers

NAME=lua-bit-numberlua-0.1.0

dist :
	rm -fr $(NAME) $(NAME).zip
	for x in `cat MANIFEST`; do install -D $$x $(NAME)/$$x; done
	zip -r $(NAME).dist $(NAME)
	cp $(NAME).dist $(NAME).zip
