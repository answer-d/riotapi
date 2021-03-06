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
    puts <<-EOS
      <html>
      <head>
      <link rel="stylesheet" type="text/css" href="/css/default.css?re=load">
      <title>keystones_#{id}(#{show_position})</title>
    EOS

    case e.code
    when 404 # ゲーム中じゃないときは30秒に一回リロードさせる
      puts <<-EOS
        <meta http-equiv="Refresh" content="30">
        </head>
        <body><p>試合開始待機中</p></body>
        </html>
      EOS
      exit 0
    else
      puts <<-EOS
        </head>
        <body><p class="error">#{e.msg_to_html}</p></body>
        </html>
      EOS
      exit 2
    end
  end

  puts ret

  exit 0
end

main

