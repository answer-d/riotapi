#!/usr/bin/ruby -Ku

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts HtmlGenerator.cgi_header
  
  # パラメータ処理
  cgi = CGI.new
  id = cgi['id']
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.cur_rank(id)
  rescue RiotAPIException => e
    puts '<p><font color="red">' + e.msg_to_html + '</font></p>'
    exit 2
  end

  puts ret

  exit 0
end

main
