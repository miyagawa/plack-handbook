#!/usr/bin/env perl
use Modern::Perl;

use Text::Markdown;

## usage: 
## script *.md

my $header = q[
<html>
<head>
<title>Plack Handbook</title>
<meta name="Author" content="Tatsuhiko Miyagawa">
<meta name="DC.date.publication" content="2012-09">
<meta name="DC.rights" content="(c) 2009-2012 Tatsuhiko Miyagawa">
</head>
<body>
];

my $mt      = Text::Markdown->new;
my $book_fh = IO::File->new("book.html", ">")
    or die $!;

local $/;
my $contents = join "\n", map {
    my $fh = IO::File->new($_, "<");
    <$fh>;
} @ARGV;

my $html = $mt->markdown($contents);
$html =~ s/<h2>/<h2 class="chapter">/g;

$book_fh->say(
    $header,
    $html, 
    "</body></html>"
);
