# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'csv'

#SUMMONER_ID = '6304677' #おれ
#SUMMONER_ID = '6160658' #rainさん
#SUMMONER_ID = '6179151' #スタンミさん
SUMMONER_ID = '6313201' #みらいさん
#SUMMONER_ID = '6172666' #SPYGEA(だれ？)
#SUMMONER_ID = '6695493' #そにろじさん

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

WIDTH=1920
ICON_WIDTH=(WIDTH*0.05).floor
ICON_HEIGHT=111
T_MARGIN=122
HEIGHT=ICON_HEIGHT*5+T_MARGIN
INS_ICON_SIDES=28

KEYSTONES = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]

mastery_list = CSV.read(File.expand_path(File.dirname($0)) + '/../data/mastery.csv')
keystone_masteries = {}
KEYSTONES.each{|item|
  tmp = mastery_list.rassoc(item)
  keystone_masteries[tmp[0]] = item if !tmp.nil?
}

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
json = JSON.load(res.body) if res.code == '200'

puts <<-EOS
  <html>
  <head>
  <meta http-equiv="Refresh" content="30">
  <title>マスタリー</title>
  </head>
  <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
  <!--
  last update : #{DateTime.now}
  -->
  <!--
  #{json}
  -->
  <table border=0 width="#{WIDTH}" height="#{HEIGHT}" cellspacing="0" cellpadding="0">
  <tr height="#{T_MARGIN}">
  <td width="#{ICON_WIDTH}"></td>
  <td width="#{WIDTH-ICON_WIDTH*2}"></td>
  <td width="#{ICON_WIDTH}"></td></tr>
  <tr>
EOS

[100,200].each{|teamId|
  puts %!<td><table border=0 width="#{ICON_WIDTH}" height="#{ICON_HEIGHT*5}" cellspacing="0" cellpadding="0">!
  json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
    part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
    part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
    puts <<-EOS
      <tr height="#{40}">
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_ICON_SIDES : INS_ICON_SIDES}">
      <font color="red">#{elem["summonerName"]}</font>
      </td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_ICON_SIDES}"></td></tr>
      <tr height="#{INS_ICON_SIDES}">
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_ICON_SIDES : INS_ICON_SIDES}">
    EOS
    puts %!<img src="./img/#{part_keystone}.png" width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 200
    puts %!</td><td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_ICON_SIDES}">!
    puts %!<img src="./img/#{part_keystone}.png" width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 100
    puts %!</td></tr><tr height="#{ICON_WIDTH - INS_ICON_SIDES - 40}"></tr>!
  } if !json.nil?
  puts %!</table></td>!
  puts %!<td></td>! if teamId == 100
}
puts %!</tr></table></body></html>!

