#!/usr/bin/env perl
use Modern::Perl;

use Text::Markdown;

## usage: 
## bin/export_html.pl *.md

my $header = qq#
<html>
<head>
<title>Plack Handbook</title>
<meta name="Author" content="Tatsuhiko Miyagawa">
<meta name="DC.date.publication" content="2012-09">
<meta name="DC.rights" content="(c) 2009-2012 Tatsuhiko Miyagawa">
<link href="images/prettify.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="images/prettify.js"></script>
</head>
<body>
#;

my $mt      = Text::Markdown->new;
my $book_fh = IO::File->new("book.html", ">")
    or die $!;

local $/;
my $contents = join "\n", map {
    my $fh = IO::File->new($_, "<");
    <$fh>;
} @ARGV;

my $html   = prepare_html($mt->markdown($contents));
my $footer = qq#
    <script>
        document.body.onload = function () { prettyPrint() };
    </script>
    </body></html>
#;

$book_fh->say(
    $header,
    $html,
    $footer,
);

sub prepare_html {
    my $html = shift;

    $html =~ s/<h2>/<h2 class="chapter">/g;
    $html =~ s/<code>/<code class="prettyprint perl">/g;

    return $html;
}
