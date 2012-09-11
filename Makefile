all: book.mobi book.epub book.zip

book.html: *.md
	./bin/export_html.rb *.md

book.mobi: book.html
#	kindlegen book.html || true
	ebook-convert book.html book.mobi

book.epub:
	ebook-convert book.html book.epub --no-default-epub-cover

book.zip:
	zip book.zip book.epub book.mobi README.md

clean:
	rm book.*
