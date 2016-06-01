.PHONY: clean

default: all

OBJECTS = \
	src.scala.pdf

all: $(OBJECTS)

$(OBJECTS):

PANDOC = pandoc
PANDOCFLAGS = \
	--standalone \
	--table-of-contents \
	--number-sections \
	--latex-engine=xelatex \
	-V documentclass=report \
	-V geometry='left=24.1mm' \
	-V geometry='right=24.1mm' \
	-V geometry='bottom=4.5cm' \
	-V fontsize=10pt \
	-V mainfont="Droid Serif" \
	-V sansfont="Droid Sans" \
	-V monofont="Droid Sans Mono Slashed" \
	-V papersize=a4paper

%.pdf: %.md
	$(PANDOC) $(PANDOCFLAGS) -o $@ $<

clean:
	rm -f *.pdf
