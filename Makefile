all: book.zip

book-en.html: en/*.md
	./bin/export_html.rb en/*.md > book-en.html

book-ja.html: ja/*.md
	./bin/export_html.rb ja/*.md > book-ja.html

plack-handbook.mobi: book-en.html
	ebook-convert book-en.html plack-handbook.mobi

plack-handbook-ja.mobi: book-ja.html
	ebook-convert book-ja.html plack-handbook-ja.mobi

plack-handbook.epub: book-en.html
	ebook-convert book-en.html plack-handbook.epub --no-default-epub-cover

plack-handbook-ja.epub: book-ja.html
	ebook-convert book-ja.html plack-handbook-ja.epub --no-default-epub-cover

book.zip: plack-handbook.mobi plack-handbook-ja.mobi plack-handbook.epub plack-handbook-ja.epub
	zip book.zip *.epub *.mobi README.md

clean:
	rm book-*.html *.epub *.mobi
