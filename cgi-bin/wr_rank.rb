#!/usr/bin/ruby -Ku

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts HtmlGenerator.cgi_header
  
  # パラメータ処理
  cgi = CGI.new
  name = cgi['name']
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.wr_cur_rank(name)
  rescue RiotAPIException => e
    puts <<-EOS
    エラーしました…<br>
    <font color="red">#{e.msg_to_html}</font>
    <hr>
    <a href="/rank.html">戻りたい</a>
    EOS

    exit 2
  end

  puts ret

  exit 0
end

main
