XDG_CONFIG_HOME ?= $$HOME/.config
FISH_HOME = $(XDG_CONFIG_HOME)/fish
FUNC_HOME = $(FISH_HOME)/functions

DOCS = `fish -c 'echo $$__fish_datadir/man'`
NAME = fishtape
FILE = $(NAME).fish
SHARE = `share/**/*.fish`
SOURCE = src/$(FILE)

MESSAGE = echo "\033[47m\033[30m$(1)\033[0m$(2)"

.PHONY: install uninstall clean test doc uninstall_doc

$(FILE): $(SOURCE) VERSION
	cat  $< > $@
	printf "function __fishtape@runtime\n" >> $@
	cat share/runtime/*.fish >> $@
	printf "end\n" >> $@
	for f in share/*.fish; do\
		printf "function __fishtape@`basename $$f .fish`\n" >> $@;\
		cat $$f >> $@;\
		printf "end\n" >> $@;\
	done
	sed "/# FISHTAPE #/r share/compiler.awk" $@ >> $@.tmp
	mv -f $@.tmp $@
	sed -E "s/(set -l fishtape_version).*/\1 `cat VERSION`/" $@ > $@.tmp
	mv $@.tmp $@

install: $(FILE)
	mkdir -p $(FUNC_HOME) && cp -f $^ $(FUNC_HOME)
	@$(call MESSAGE,DONE. Run '$(NAME) --help' or 'make doc' to build the man page.)

uninstall:
	rm -f $(FUNC_HOME)/$(FILE)
	@$(call MESSAGE,DONE. Run 'functions -e $(NAME)' to completely remove $(NAME))

clean:
	rm -f $(FILE) $(FILE).tmp

test:
	fish -c "fishtape test/*.fish"

doc:
	for m in 1 7; do \
		mkdir -p $(DOCS)/man$$m;\
		if type ronn 2>/dev/null 1>&2; then \
			ronn --manual=$(NAME) -r man/man$$m/$(NAME).md;\
		fi;\
		cp man/man$$m/$(NAME).$$m $(DOCS)/man$$m/$(NAME).$$m;\
	done
	@$(call MESSAGE,DONE. See '$(NAME)(1)' and '$(NAME)(7)')

uninstall_doc:
	for m in 1 7; do rm -f $(DOCS)/man$$m/$(NAME).$$m; done
