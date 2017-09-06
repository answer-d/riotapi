#!/usr/bin/ruby -Ku

=begin
サモナーIDをパラメータから受け取ってhtml生成器に渡す
成功したらそのURIを表示する
そんな感じのCGI
=end

require 'cgi'
require_relative '../script/html_generator.rb'

def main
  puts HtmlGenerator.cgi_header
  
  # 多重起動制御
  #proc_count = `ps -ef | grep #$0 | grep -v grep | wc -l`.to_i
  #if proc_count > 1
  #  puts '<p>他に実行中の人がいます、ちょっと待ってから再実行たのまい</p>'
  #  puts_footer
  #  exit 1
  #end
  
  # パラメータ処理
  cgi = CGI.new
  id = cgi['id']
  show_position = cgi['show_position'] == 'true' ? true : false
  
  # html生成器に渡す
  begin
    ret = HtmlGenerator.cur_keystones(id, show_position)
  rescue RiotAPIException => e
    case e.code
    when 404 # ゲーム中じゃないときは30秒に一回リロードさせる
      puts <<-EOS
        <html>
        <head><meta http-equiv="Refresh" content="30"></head>
        <body><font color="white">試合開始待機中</font></body>
        </html>
      EOS
    else
      puts '<p><font color="red">' + e.msg_to_html + '</font></p>'
      exit 2
    end
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

