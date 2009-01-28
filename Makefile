PREFIX	=/opt
BINDIR	=${PREFIX}/bin

all:	bootstrap.zsh

install:bootstrap.zsh
	install -D -c bootstrap.zsh ${BINDIR}/bootstrap

uninstall:
	${RM} ${BINDIR}/bootstrap
