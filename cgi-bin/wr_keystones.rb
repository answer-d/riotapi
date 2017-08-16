#!/usr/bin/ruby -Ku

=begin
サモナーIDをパラメータから受け取ってhtml生成器に渡す
成功したらそのURIを表示する
そんな感じのCGI
=end

require 'cgi'
require "#{File.expand_path(File.dirname(__FILE__))}/../script/html_generator.rb"

# ヘッダ的なところ
puts <<-EOS
Content-type: text/html

<html>
<head><title>誘導ぺーじ</title></html>
<body>
EOS

# 多重起動制御
proc_count = `ps -ef | grep #$0 | grep -v grep | wc -l`.to_i
if proc_count > 1
  puts '他に実行中の人がいます、ちょっと待ってから再実行たのまい<hr><a href="/">戻りたい</a></body></html>'
  exit 1
end

# パラメータ処理
cgi = CGI.new
name = cgi['name']
puts "サモナーネーム：#{name}<br>"

# html生成器に渡す
begin
  ret = HtmlGenerator.cur_keystones(name)
rescue RiotAPIException => e
  puts e.msg + '<hr><a href="/">戻りたい</a></body></html>'
  exit
end

uri = "http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/overlay/#{ret}.html"
puts <<-EOS
  下のURLをブラウザソースとして取り込んで下さいな！<br>
  <a href="#{uri}" target="_blank"><h1>#{uri}</h1></a>
  <hr>
  ★このへんに使い方とかcssとかの設定書く
EOS

# フッタ的な
puts <<-EOS
<hr><a href="/">戻りたい</a>
</body></html>
EOS

