#!/usr/bin/env ruby
require 'redcarpet'

HEADER = <<HEAD
<html>
<head>
<title>Plack Handbook</title>
<meta name="Author" content="Tatsuhiko Miyagawa">
<meta name="DC.date.publication" content="2012-09">
<meta name="DC.rights" content="(c) 2009-2012 Tatsuhiko Miyagawa">
</head>
<body>
HEAD

def munge(html)
  html.gsub /<h2>/, '<h2 class="chapter">'
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
STDOUT.write HEADER
STDOUT.write munge(markdown.render(ARGF.readlines.join ''))
STDOUT.write "</body></html>\n"

