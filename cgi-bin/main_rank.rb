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
    puts <<-EOS
      <html>
      <head>
      <link rel="stylesheet" type="text/css" href="/css/default.css?re=load">
      <title>rank_#{id}</title>
      </head>
      <body>
      <p class="error">#{e.msg_to_html}</p>
      </body>
      </html>
      EOS
    exit 2
  end

  puts ret

  exit 0
end

main
