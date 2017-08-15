#!/usr/bin/ruby -Ku

require 'cgi'
require "#{File.expand_path(File.dirname($0))}/../script/cur_keystones.rb"

puts "Content-type: text/html\n\n"

cgi = CGI.new
name = cgi['name']

ret = generate_html(name)
#ret = $?
if ret.nil?
  puts "何らかの何かが発生しました"
else
  puts "http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/#{ret}.html"
end
puts '<br><a href="/index.html">戻りたい</a>'

