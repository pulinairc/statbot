## Makefile for moxbot -- an irc quizbot
#
## $Id: Makefile,v 1.46 2002/07/05 19:14:21 chat Exp $

PACKAGE = moxquizz

DISTFILES = Makefile moxquizz.conf moxquizz.rc \
	moxquizz.tcl moxtools.tcl moxfun.tcl \
	supplemental/allstars.pl supplemental/setup.pl \
	README.translation intl/*.msg intl/*/*.txt \
	quizdata/questions.bleistift.edited.de\
	quizdata/questions.de \
	quizdata/questions.quake.de \
	quizdata/questions.viper.de \
	quizdata/questions.quizzen.de \
	quizdata/questions.user.de \
	quizdata/questions.dtron.en \
	quizdata/questions.imran.en \
	quizdata/questions.ollypomm.en \
	quizdata/questions.serv.en \
	quizdata/questions.trivia.en \
	quizdata/questions.trivia2.en \
	quizdata/questions.user.en \
	quizdata/questions*.es \
	quizdata/questions*.my \
	quizdata/questions*.no \
	README README.database README.windows \
	INSTALL CHANGES NEWS UPGRADING

FUNDISTFILES = moxfun.tcl README.moxfun \
	intl/*/weicheier.txt intl/*/harteier.txt \
	intl/*/phrases.txt

LANGFILES = README.translation intl/de.msg  intl/en/*.txt  intl/de/*.txt

# make a distribution
dist:
	@VERSION=`grep '^set version_moxquizz' moxquizz.tcl | sed 's/.*\"\(.*\)\".*/\1/'` ;\
	PACKNAME=$(PACKAGE)-$$VERSION ;\
	FILENAME=$$PACKNAME.tar ;\
	echo +---- packing $$FILENAME ;\
	rm -r $$PACKNAME ;\
	mkdir $$PACKNAME ;\
	ln -s $$PACKNAME $(PACKAGE) ;\
	tar cf - $(DISTFILES) LICENSE $(FUNDISTFILES) | (cd $$PACKNAME; tar xf -) ;\
	tar cvf $$FILENAME $$PACKNAME $(PACKAGE) ;\
	rm -r $$PACKNAME ;\
	rm $(PACKAGE) ;\
	echo +---- compressing ;\
	rm $$FILENAME.gz ;\
	gzip -v $$FILENAME ;\
	echo +---- done ;\
	ls -l $$FILENAME*


fundist:
	@VERSION=`grep '^set version_moxfun' moxfun.tcl | sed 's/.*\"\(.*\)\".*/\1/'` ;\
	PACKNAME=moxfun-$$VERSION ;\
	FILENAME=$$PACKNAME.tar ;\
	echo +---- packing $$FILENAME ;\
	mkdir $(PACKAGE) ;\
	tar cf - $(FUNDISTFILES) LICENSE | (cd $(PACKAGE); tar xf -) ;\
	tar cvf $$FILENAME  $(PACKAGE) ;\
	rm -r $(PACKAGE) ;\
	echo +---- compressing ;\
	rm $$FILENAME.gz ;\
	gzip -v $$FILENAME ;\
	echo +---- done ;\
	ls -l $$FILENAME*

langdist:
	PACKNAME=moxlang-`date +%Y%m%d` ;\
	FILENAME=$$PACKNAME.tar ;\
	echo +---- packing $$FILENAME ;\
	mkdir $(PACKAGE) ;\
	tar cf - $(LANGFILES) LICENSE | (cd $(PACKAGE); tar xf -) ;\
	tar cvf $$FILENAME  $(PACKAGE) ;\
	rm -r $(PACKAGE) ;\
	echo +---- compressing ;\
	rm $$FILENAME.gz ;\
	gzip -v $$FILENAME ;\
	echo +---- done ;\
	ls -l $$FILENAME*


# pack question files
qdist:
	PACKNAME=$(PACKAGE)-questions-`date +%Y%m%d` ;\
	-rm $(PACKAGE)-questions* ;\
	tar cvf $$PACKNAME.tar `find quizdata/questions*.en quizdata/questions*.de quizdata/questions*.es quizdata/questions*.my ` ;\
	ls -l $$PACKNAME.tar ;\
	bzip2 $$PACKNAME.tar ;\
	ls -l $$PACKNAME.tar.bz2
