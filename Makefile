PREFIX	=/opt
BINDIR	=${PREFIX}/bin

all:	bootstrap.sh

install:bootstrap.sh
	install -d ${BINDIR}
	install -c bootstrap.sh ${BINDIR}/bootstrap

uninstall:
	${RM} ${BINDIR}/bootstrap

check:	bootstrap.sh
