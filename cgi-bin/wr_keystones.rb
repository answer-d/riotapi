#!/usr/bin/ruby -Ku

require 'cgi'
require "#{File.expand_path(File.dirname($0))}/../script/cur_keystones.rb"

puts <<-EOS
Content-type: text/html

<html>
<head><title>誘導ぺーじ</title></html>
<body>
EOS

proc_count = `ps -ef | grep #$0 | grep -v grep | wc -l`.to_i
if proc_count > 1
  puts '他に実行中の人がいます、ちょっと待って再実行たのまい<hr><a href="/index.html">戻りたい</a></body></html>'
  exit 1
end

cgi = CGI.new
name = cgi['name']

puts "サモナーネーム：#{name}<br>"

ret = generate_html(name)
puts "何らかの何かが発生しました" if ret.nil?
case ret
when 400
  puts "<br>ベリーバッドなリクエスト、おこです"
when 403
  puts "<br>APIキーが切れてるかもしれない祭り開催中なのであんでぃーを怒れ"
when 404
  puts "<br>サモナーネームが存在しないかゲーム中じゃないか"
when 429
  puts "<br>れーとりみっとです、加減してくださいお願いします何でもしますから(何でもするとは言っていない)"
else
  puts <<-EOS
    下のURLをブラウザソースとして取り込んで下さいな！<br>
    <h1>http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/overlay/#{ret}.html</h1><br>
    ★このへんにcssとかの設定書く
  EOS
end

puts <<-EOS
<hr><a href="/index.html">戻りたい</a>
</body></html>
EOS


