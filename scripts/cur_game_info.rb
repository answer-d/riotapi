# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'csv'

#SUMMONER_ID = '6304677' #おれ
#SUMMONER_ID = '6160658' #rainさん
SUMMONER_ID = '6179151' #スタンミさん

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

WIDTH=1920
HEIGHT=677

KEYSTONES = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]

mastery_list = CSV.read(File.expand_path(File.dirname($0)) + '/../data/mastery.csv')
keystone_masteries = {}
KEYSTONES.each{|item|
  tmp = mastery_list.rassoc(item)
  keystone_masteries[tmp[0]] = item if !tmp.nil?
}

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)

if res.code != '200'
  puts <<EOS
<html>
<head>
<meta http-equiv="Refresh" content="5">
<title>200以外だぁ</title>
</head>
<body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<table border=0 width="#{WIDTH}" height="#{HEIGHT}" cellspacing="0" cellpadding="0"><tr><td></td></tr></table>
</body>
</html>
EOS
  exit
end

json = JSON.load(res.body)

puts <<EOS
<html>
<head>
<meta http-equiv="Refresh" content="5">
<title>マスタリー</title>
</head>
<body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<table border=0 width="#{WIDTH}" height="#{HEIGHT}" cellspacing="0" cellpadding="0">
<tr height="122"><td width="97"></td><td width="1726"></td><td width="97"></td></tr><tr>
EOS

[100,200].each{|teamId|
  puts "<td><table border=0 width=\"97\" height=\"555\" cellspacing=\"0\" cellpadding=\"0\" bgcolor=\"red\">"
  json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
    puts "<tr height=\"111\"><td width=\"97\">"
    puts "<font size=\"1\" color=\"white\">#{elem["summonerName"]}(#{elem["summonerId"]})</font><br>"
    
    #ここにマスタリ検索処理
    part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
    part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
    puts "<font size=\"1\" color=\"white\">#{keystone_masteries[part_keystone]}(#{part_keystone})</font>"
    
    #puts "#{elem["teamId"]}"
    puts "</td></tr>"
  }
  puts "</table></td>"
  puts "<td></td>" if teamId == 100
}

puts <<EOS
</tr>
</table>
</body>
</html>
EOS

