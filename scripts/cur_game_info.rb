# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'csv'

#SUMMONER_ID = '6304677' #おれ
SUMMONER_ID = '6160658' #rainさん

APIKEY = 'RGAPI-ba4d7259-f0ca-4d35-85ad-64f70f1739a0'
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
if res.code != '200'
  puts <<EOS
<html>
<head>
<title>200以外だぁ</title>
</head>
<body>
</body>
</html>
EOS
  exit
end

json = JSON.load(res.body)

puts <<EOS
<html>
<head>
<title>マスタリー</title>
</head>
<body>
<table border=1>
<tr><td></td><td></td><td></td></tr><tr>
EOS

# blue side
puts "<td><table border=1>"
json["participants"].select{|elem| elem["teamId"] == 100}.each{|elem|
  puts "<tr><td>"
  puts "#{elem["summonerName"]}(#{elem["summonerId"]})<br>"
  #ここにマスタリ検索処理
  puts "#{elem["teamId"]}"
  puts "</td></tr>"
}
puts "</table></td>"

puts "<td></td>"

# red side
puts "<td><table border=1>"
json["participants"].select{|elem| elem["teamId"] == 200}.each{|elem|
  puts "<tr><td>"
  puts "#{elem["summonerName"]}(#{elem["summonerId"]})<br>"
  #ここにマスタリ検索処理
  puts "#{elem["teamId"]}"
  puts "</td></tr>"
}
puts "</table></td>"

puts <<EOS
</tr><tr><td></td><td></td><td></td></tr>
</table>
</body>
</html>
EOS

