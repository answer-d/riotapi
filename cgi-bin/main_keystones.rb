#!/usr/bin/ruby -Ku

=begin
サモナーIDをパラメータから受け取ってhtml生成器に渡す
成功したらそのURIを表示する
そんな感じのCGI
=end

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts_header
  
  # 多重起動制御
  proc_count = `ps -ef | grep #$0 | grep -v grep | wc -l`.to_i
  if proc_count > 1
    puts '<p>他に実行中の人がいます、ちょっと待ってから再実行たのまい</p>'
    puts_footer
    exit 1
  end
  
  # パラメータ処理
  cgi = CGI.new
  name = cgi['name']
  puts "<p>サモナーネーム：#{name}</p>"
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.cur_keystones(name)
  rescue RiotAPIException => e
    puts '<p><font color="red">' + e.msg + '</font></p>'
    puts_footer
    exit 2
  end

  uri = "http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/overlay/#{ret}.html"
  puts <<-EOS
    <p>
    下のURLをブラウザソースとして取り込んで下さいな！<br>
    <a href="#{uri}" target="_blank"><h1>#{uri}</h1></a>
    </p>
    <hr>
    <p>
    ★このへんに使い方とかcssとかの設定書く
    </p>
  EOS

  puts_footer
  exit 0
end

# ヘッダ的なところ
def puts_header()
  puts <<-EOS
Content-type: text/html

<html><head><title>誘導ぺーじ</title></html><body>
  EOS
end

# フッタ的なところ
def puts_footer()
  puts <<-EOS
<hr><a href="/">戻りたい</a></body></html>
  EOS
end

main

