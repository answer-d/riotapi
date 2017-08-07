# 毎分実行
# html generator

require 'net/http'
require 'uri'
require 'json'
require 'csv'

#SUMMONER_ID = '6304677' #おれ
#SUMMONER_ID = '6160658' #rainさん
#SUMMONER_ID = '6179151' #スタンミさん
#SUMMONER_ID = '6313201' #みらいさん
SUMMONER_ID = '6172666' #SPYGEA(だれ？)

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

WIDTH=1920
ICON_WIDTH=(WIDTH*0.05).floor
ICON_HEIGHT=111
T_MARGIN=122
HEIGHT=ICON_HEIGHT*5+T_MARGIN
INS_ICON_SIDES=32

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
  <table border=0 width="#{WIDTH}" height="#{HEIGHT}" cellspacing="0" cellpadding="0">
  <tr height="#{T_MARGIN}">
  <td width="#{ICON_WIDTH}"></td>
  <td width="#{WIDTH-ICON_WIDTH*2}"></td>
  <td width="#{ICON_WIDTH}"></td></tr>
  <tr>
EOS

[100,200].each{|teamId|
  puts <<-EOS
    <td bgcolor="blue">
    <table border=0 width="#{ICON_WIDTH}" height="#{ICON_HEIGHT*5}" cellspacing="0" cellpadding="0">
  EOS
  json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
    part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
    part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
    puts <<-EOS
      <tr height="#{ICON_HEIGHT - INS_ICON_SIDES}">
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_ICON_SIDES : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_ICON_SIDES}"></td></tr>
      <tr height="#{INS_ICON_SIDES}">
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_ICON_SIDES : INS_ICON_SIDES}" #{'bgcolor="red"' if teamId == 200}>
      #{'<img src="./img/' + part_keystone + '.png" width="' + INS_ICON_SIDES.to_s + '" height="' + INS_ICON_SIDES.to_s + '">' if teamId == 200}</td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_ICON_SIDES}" #{'bgcolor="red"' if teamId == 100}>
      #{'<img src="./img/' + part_keystone + '.png" width="' + INS_ICON_SIDES.to_s + '" height="' + INS_ICON_SIDES.to_s + '">' if teamId == 100}</td></tr>
    EOS
=begin
    puts <<-EOS
      <tr height="#{ICON_HEIGHT}"><td width="#{ICON_WIDTH}">
      <font size="1" color="white">
      #{elem["summonerName"]}(#{elem["summonerId"]})<br>
      #{keystone_masteries[part_keystone]}(#{part_keystone})</font>
      </td></tr>
    EOS
=end
  } if !json.nil?
  puts "</table></td>"
  puts "<td></td>" if teamId == 100
}

puts <<-EOS
  </tr>
  </table>
  </body>
  </html>
EOS

