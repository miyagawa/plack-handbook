all: book.mobi book.epub

book.html: *.md
	./bin/export_html.rb *.md

book.mobi: book.html
#	kindlegen book.html || true
	ebook-convert book.html book.mobi --mobi-toc-at-start

book.epub:
	ebook-convert book.html book.epub --no-default-epub-cover

clean:
	rm book.*
