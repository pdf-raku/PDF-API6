DocProj=pdf-raku.github.io
DocRepo=https://github.com/pdf-raku/$(DocProj)
TocMaker=../$(DocProj)/etc/make-toc.raku

$(TocMaker) :
	(cd .. && git clone $(DocRepo) $(DocProj))

all : doc

doc : previews toc

# previews are generated by the test suite
previews :
	@raku -M PDF::To::Cairo -c;
	@rm -f tmp/.previews/*.png;
	@prove6 -I . t/01-readme.t;
	pdf-previews.raku tmp/;
	git add -f tmp/.previews/*.png;

toc :
	@raku $(TocMaker) README.md > README.tmp;
	@mv README.tmp README.md;

test :
	@prove6 -I . t
