=begin
現在のランク情報をhtml形式で標準出力に書くやつ
=end

require 'date'
require "#{File.expand_path(File.dirname(__FILE__))}/api_caller.rb"

summoner_id = '6304677' #あんでぃー
refresh_rate = '30' #秒
window_width = '256' #px
window_height = '64' #px
icon_sides = '64' #px
font_options = 'size="5" color="white"'

hash = APICaller.position_byid(summoner_id)

buf = ""
buf += <<-EOS
  <html>
  <head>
  <meta http-equiv="Refresh" content="#{refresh_rate}">
  <title>レート</title>
  </head>
  <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
  <!-- last update : #{DateTime.now} -->
  <table border=0 width="#{window_width}" height="#{window_height}" cellspacing="0" cellpadding="0">
  <tr><td width="#{icon_sides}">
  <img src=./img/#{hash.nil? ? 'UNRANK' : hash["tier"]+hash["rank"]}.png width="#{icon_sides}" height="#{icon_sides}">
  </td><td>
  <b><font #{font_options}>#{hash["tier"]} #{hash["rank"]}<br>#{hash["leaguePoints"]}LP</font></b>
  </td></tr>
  </table>
  </body>
  </html>
EOS

puts buf

