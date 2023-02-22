alias b := build
alias c := clean
alias ca := clear-appendices
alias w := watch

# this is needed for TeXstudio to find all the files properly in ~/.texlive on my local install
export PATH := env_var("HOME") + "/.texlive/2021/bin/x86_64-linux:" + env_var("PATH")

# build the PDF
build: process-code-snippets
	@mkdir -p tikz-imgs
	latexmk -lualatex -jobname=main -file-line-error -halt-on-error -interaction=nonstopmode -shell-escape -cd main

# clean all the auxiliary files generated by compilation
clean:
	fd -I -e log -e aux -e dvi -e lof -e lot -e bit -e idx -e glo -e bbl -e bcf -e ilg -e toc -e ind -e out -e blg -e fdb_latexmk -e fls -e run.xml -e synctex.gz -X rm -f
	fd -I -e dpth -e md5 -e auxlock -X rm -f sections/processed_*.tex sections/development/processed_*.tex
	rm -rf _minted-main/ tikz-imgs/

# watch all the tex files and build the PDF when any of them change
watch:
	while fd -e tex -X inotifywait -e modify -qq; do just build; done

# process the code snippet comments and create `processed_` files
process-code-snippets:
	cd {{justfile_directory()}}/process-code-snippets && LINTRANS_DIR={{justfile_directory()}}/lintrans cargo build --release
	fd . sections/development/ -e tex -E 'processed*' -X ./process-code-snippets/target/release/process-code-snippets sections/development.tex

# clean the files generated by snippet processing
clean-processed-files:
	rm -f sections/processed_*.tex sections/development/processed_*.tex

# clear the generated appendix files
clear-appendices:
	sd -f ms '(\\begin\{document\}).+(\\end\{document\})' '$1\nProject code\n$2' sections/appendices/project_code.tex
	sd -f ms '(\\begin\{document\}).+(\\end\{document\})' '$1\nTesting code\n$2' sections/appendices/testing_code.tex

# build the PDF in the Docker container (very slow)
build-docker:
	docker build -t write-up-lintrans .
	docker run --name wul write-up-lintrans
	docker cp wul:/write-up-lintrans/main.pdf ./lintrans.pdf
	docker rm wul
