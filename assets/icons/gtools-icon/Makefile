all:
	mkdir -p text
	xelatex gtools-icon.tex
	rm -f gtools-icon.aux
	rm -f gtools-icon.log
	rm -f gtools-icon.fls
	rm -f gtools-icon.log
	rm -f .latexrun.*
	convert -density 600 gtools-icon.pdf\[0\] gtools-icon-text-open-sans.svg
	convert -density 600 gtools-icon.pdf\[2\] gtools-icon-text-ubuntu.svg
	convert gtools-icon-text-open-sans.svg gtools-icon-text-open-sans.png
	convert gtools-icon-text-open-sans.png -fuzz 0% -transparent white gtools-icon-text-open-sans.png
	convert gtools-icon-text-ubuntu.svg gtools-icon-text-ubuntu.png
	convert gtools-icon-text-ubuntu.png -fuzz 0% -transparent white gtools-icon-text-ubuntu.png
	cp -f gtools-icon-text-ubuntu.png gtools-icon-text.png
