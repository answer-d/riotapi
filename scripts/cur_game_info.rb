# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'csv'

#SUMMONER_ID = '6304677' #おれ
#SUMMONER_ID = '6160658' #rainさん
#SUMMONER_ID = '' #

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

WIDTH=1920
HEIGHT=1080

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
<title>マスタリー</title>
</head>
<body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<table border=1 width="#{WIDTH}" height="#{HEIGHT}" cellspacing="0" cellpadding="0">
<tr height="#{HEIGHT*0.1}"><td width="#{WIDTH*0.1}"></td><td width="#{WIDTH*0.8}"></td><td width="#{WIDTH*0.1}"></td></tr><tr height="#{HEIGHT*0.8}">
EOS

[100,200].each{|teamId|
  puts "<td><table width=\"#{WIDTH*0.1}\" height=\"#{HEIGHT*0.8}\" cellspacing=\"0\" cellpadding=\"0\">"
  json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
    puts "<tr><td>"
    puts "#{elem["summonerName"]}(#{elem["summonerId"]})<br>"
    #ここにマスタリ検索処理
    p elem["masteries"].map{|hash| hash["masteryId"]}
    #puts "#{elem["teamId"]}"
    puts "</td></tr>"
  }
  puts "</table></td>"
  puts "<td></td>" if teamId == 100
}

puts <<EOS
</tr><tr height="#{HEIGHT*0.1}"><td></td><td></td><td></td></tr>
</table>
</body>
</html>
EOS

