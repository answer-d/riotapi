#!/usr/bin/ruby -Ku

require 'cgi'
require "#{File.expand_path(File.dirname($0))}/../script/cur_keystones.rb"

#ここに同時起動制御入れよう


puts <<-EOS
Content-type: text/html

<html>
<head><title>誘導ぺーじ</title></html>
<body>
EOS

cgi = CGI.new
name = cgi['name']

puts "<!-- #{name} -->"

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
    <h1>http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/#{ret}.html</h1><br>
    ★このへんにcssとかの設定書く
  EOS
end

puts <<-EOS
<hr><a href="/index.html">戻りたい</a>
</body></html>
EOS


