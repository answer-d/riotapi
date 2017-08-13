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
#SUMMONER_ID = '6172666' #SPYGEAさん(だれ？)
#SUMMONER_ID = '6695493' #そにろじさん
#SUMMONER_ID = '8760255' #UGさん
#SUMMONER_ID = '7051645' #まゆりさん
#SUMMONER_ID = '6188121' #なぎさっちさん
#SUMMONER_ID = '6416807' #damさん
SUMMONER_ID = '6470919' #yanyantkbさん

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/spectator/v3/active-games/by-summoner/' + SUMMONER_ID
URI_FOOT = "?api_key=#{APIKEY}"

WIDTH=1920
ICON_WIDTH=(WIDTH*0.05).floor+1
ICON_HEIGHT=111
T_MARGIN=122
HEIGHT=ICON_HEIGHT*5+T_MARGIN

KEYSTONES = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]

mastery_list = CSV.read(File.expand_path(File.dirname($0)) + '/../data/mastery.csv')
keystone_masteries = {}
KEYSTONES.each{|item|
  tmp = mastery_list.rassoc(item)
  keystone_masteries[tmp[0]] = item if !tmp.nil?
}

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)

exit if res.code != '200'

json = JSON.load(res.body)

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

INS_ICON_SIDES=28
INS_L_MARGIN=32
INS_T_MARGIN=15
INS_V_MARGIN=7

[100,200].each{|teamId|
  puts %!<td><table border=0 width="#{ICON_WIDTH}" height="#{ICON_HEIGHT*5}" cellspacing="0" cellpadding="0">!
  json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
    part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
    part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
    
    l_api = '/lol/league/v3/positions/by-summoner/' + elem["summonerId"].to_s
    l_uri = URI.parse URI.encode("#{URI_HEAD}#{l_api}#{URI_FOOT}")

    puts "<!--#{l_uri}-->"

    l_res = Net::HTTP.get_response(l_uri)

    puts "<!--#{l_res.body}-->"

    l_json = JSON.load(l_res.body).at(0)
    
    puts <<-EOS
      <!--#{l_json}-->
      <tr height="#{INS_T_MARGIN}">
      <td width="#{teamId == 100 ? INS_L_MARGIN : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2}"></td>
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2 : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : INS_L_MARGIN}"></td>
      </tr>
      <tr height="#{INS_ICON_SIDES}">
      <td width="#{teamId == 100 ? INS_L_MARGIN : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2}">
    EOS
    #puts %!<div style="background-color : red"><img src=./img/#{l_json["tier"]}.png width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}"></div>! if teamId == 100
    puts %!<img src=./img/#{l_json["tier"]}.png width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 100

    puts <<-EOS
      </td>
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2 : INS_ICON_SIDES}">
    EOS
    #puts %!<div style="background-color : red"><img src=./img/#{l_json["tier"]}.png width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}"></div>! if teamId == 200
    puts %!<img src=./img/#{l_json["tier"]}.png width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 200

    puts <<-EOS
      </td><td width="#{teamId == 100 ? INS_ICON_SIDES : INS_L_MARGIN}"></td>
      </tr>
      <tr height="#{INS_V_MARGIN}">
      <td width="#{teamId == 100 ? INS_L_MARGIN : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2}"></td>
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2 : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : INS_L_MARGIN}"></td>
      </tr>
      <tr height="#{INS_ICON_SIDES}">
      <td width="#{teamId == 100 ? INS_L_MARGIN : INS_ICON_SIDES}">
    EOS
    puts %!<img src="./img/#{part_keystone}.png" width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 200
    puts <<-EOS
      </td><td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2}"></td>
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2 : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : INS_L_MARGIN}">
    EOS
    puts %!<img src="./img/#{part_keystone}.png" width="#{INS_ICON_SIDES}" height="#{INS_ICON_SIDES}">! if teamId == 100
    puts <<-EOS
      </td></tr>
      <tr height="#{ICON_HEIGHT - INS_T_MARGIN - INS_V_MARGIN - INS_ICON_SIDES*2}">
      <td width="#{teamId == 100 ? INS_L_MARGIN : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2}"></td>
      <td width="#{teamId == 100 ? ICON_WIDTH - INS_L_MARGIN - INS_ICON_SIDES*2 : INS_ICON_SIDES}"></td>
      <td width="#{teamId == 100 ? INS_ICON_SIDES : INS_L_MARGIN}"></td>
      </tr>
    EOS
  } if !json.nil?
  puts %!</table></td>!
  puts %!<td></td>! if teamId == 100
}
puts %!</tr></table></body></html>!

