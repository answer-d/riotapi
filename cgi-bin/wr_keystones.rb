#!/usr/bin/ruby -Ku

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts HtmlGenerator.cgi_header
  
  # パラメータ処理
  cgi = CGI.new
  name = cgi['name']
  show_position = cgi['show_position']
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.wr_cur_keystones(name, show_position)
  rescue RiotAPIException => e
    puts <<-EOS
    <html>
    <head>
    <title>ますたりーをあれするやつ</title>
    </head>
    <body>
    <h1>観戦モードでキーストーンマスタリーをいい感じに表示するオーバーレイ生成器</h1>
    <hr>
    <p>
    エラーしました…<br>
    <font color="red">#{e.msg_to_html}</font>
    <hr>
    <a href="/keystone.html">戻りたい</a>
    </body>
    </html>
    EOS

    exit 2
  end

  puts ret

  exit 0
end

main
