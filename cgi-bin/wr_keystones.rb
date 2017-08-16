#!/usr/bin/ruby -Ku

=begin
サモナーIDをパラメータから受け取ってhtml生成器に渡す
成功したらそのURIを表示する
そんな感じのCGI
=end

require 'cgi'
require "#{File.expand_path(File.dirname(__FILE__))}/../script/cur_keystones.rb"

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
  puts '他に実行中の人がいます、ちょっと待って再実行たのまい<hr><a href="/index.html">戻りたい</a></body></html>'
  exit 1
end

# パラメータ受け取ってhtml生成器に渡す
cgi = CGI.new
name = cgi['name']
puts "サモナーネーム：#{name}<br>"
ret = generate_html(name)

# 返り値がサモナーIDじゃなかったらエラー処理
# サモナーIDだったら生成されたと思われるhtmlのURIを画面に表示
if ret.nil?
  puts "html生成で何らかの何かが発生しました(nil)"
elsif ret < 1000
  case ret
  when 400
    puts "<br>ベリーバッドなリクエスト、おこです"
  when 403
    puts "<br>APIキーが切れてるかもしれない祭り。あんでぃーを怒れ"
  when 404
    puts "<br>サモナーネームが存在しないかゲーム中じゃないか"
  when 429
    puts "<br>れーとりみっとです、加減してくださいお願いします何でもしますから(何でもするとは言っていない)"
  else
    puts "<br>変なステータスコードが返っているぞ上を見ろ"
  end
else
  uri = "http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/overlay/#{ret}.html"
  puts <<-EOS
    下のURLをブラウザソースとして取り込んで下さいな！<br>
    <a href="#{uri}" target="_blank"><h1>#{uri}</h1></a>
    <hr>
    ★このへんに使い方とかcssとかの設定書く
  EOS
end

# フッタ的な
puts <<-EOS
<hr><a href="/">戻りたい</a>
</body></html>
EOS

