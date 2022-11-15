# build the PDF
build:
	@mkdir -p tikz-imgs
	python process_code_snippets.py
	latexmk -lualatex -jobname=main -file-line-error -halt-on-error -interaction=batchmode -shell-escape -cd main

# clean all the auxiliary files generated by compilation
clean:
	fd -I -e log -e aux -e dvi -e lof -e lot -e bit -e idx -e glo -e bbl -e bcf -e ilg -e toc -e ind -e out -e blg -e fdb_latexmk -e fls -e run.xml -e synctex.gz | xargs rm -f
	fd -I -e dpth -e md5 -e auxlock | xargs rm -f sections/processed_*.tex sections/development/processed_*.tex
	rm -rf _minted-main/ tikz-imgs/

# watch all the tex files and build the PDF when any of them change
watch:
	while fd -e tex -X inotifywait -e modify -qq; do just build; done

# clear the generated appendix files
clear-appendices:
	sd -f ms '(\\begin\{document\}).+(\\end\{document\})' '$1\nProject code\n$2' sections/appendices/project_code.tex
	sd -f ms '(\\begin\{document\}).+(\\end\{document\})' '$1\nTesting code\n$2' sections/appendices/testing_code.tex
