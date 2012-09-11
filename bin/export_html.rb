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

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
File.open('book.html', 'w') do |io|
  io.write HEADER
  io.write markdown.render(ARGF.readlines.join '')
  io.write "</body></html>\n"
end

