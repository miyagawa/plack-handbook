#!/usr/bin/env ruby
require 'redcarpet'

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
File.open('book.html', 'w') do |io|
  io.write "<html><head><title>Plack Handbook</title></head><body>\n"
  io.write markdown.render(ARGF.readlines.join '')
  io.write "</body></html>\n"
end

