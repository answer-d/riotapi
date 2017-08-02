# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'

SUMMONER_ID = '6304677'

APIKEY = 'RGAPI-ba4d7259-f0ca-4d35-85ad-64f70f1739a0'
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/league/v3/positions/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
list = JSON.load(res.body)
hash = list[0]

#puts "#{hash["tier"]} #{hash["rank"]} #{hash["leaguePoints"]}LP"

puts <<EOS
<html>
<head>
<title>レート</title>
</head>
<body>
<table border=0>
<tr><th align="center">
<font size="5">#{hash["tier"]} #{hash["rank"]} #{hash["leaguePoints"]}LP</font>
</th></tr>
<tr><td align="center">
<img src=./img/#{hash["tier"]}.png width="128" height="128">
</td></tr>
</table>
</body>
</html>
EOS

