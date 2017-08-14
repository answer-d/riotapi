# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'date'

SUMMONER_ID = '6304677'

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/league/v3/positions/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)

puts <<-EOS
  <html>
  <head>
  <meta http-equiv="Refresh" content="30">
  <title>レート</title>
  </head>
  <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
  <!--
  last update : #{DateTime.now}
  -->
EOS

if res.code == '403'
  puts '<font color="white">APIキー確認</font></body></html>'
  exit
elsif res.code == '429'
  puts '<font color="white">Rate Limit</font></body></html>'
  exit
end

list = JSON.load(res.body)
hash = list[0]

puts <<-EOS
  <table border=0 width="256" height="64" cellspacing="0" cellpadding="0">
  <tr><td width="64">
  <img src=./img/#{hash.nil? ? 'UNRANK' : hash["tier"]+hash["rank"]}.png width="64" height="64">
  </td><td>
  <b><font size="5" color="white">
    #{hash["tier"]} #{hash["rank"]}<br>
    #{hash["leaguePoints"]}LP
  </font></b>
  </td></tr>
  </table>
  </body>
  </html>
EOS

