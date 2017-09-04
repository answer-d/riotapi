#!/usr/bin/ruby -Ku

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts_header
  
  # パラメータ処理
  cgi = CGI.new
  id = cgi['id']
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.cur_rank(id)
  rescue RiotAPIException => e
    puts e.msg
    exit 2
  end

  puts ret

  exit 0
end

# ヘッダ的なところ
def puts_header()
  puts <<-EOS
Content-type: text/html

  EOS
end

main

