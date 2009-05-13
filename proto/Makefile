all: mmb_pr.pdf

%.dvi: %.tex
	latex $<
%.ps: %.dvi
	dvips $< -o $@
%.pdf: %.ps
	ps2pdf $< $@

clean:
	rm -f -- *.dvi *.ps *.pdf *.aux *.log