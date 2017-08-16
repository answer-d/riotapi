require 'csv'
require "#{File.expand_path(File.dirname($0))}/api_caller.rb"

#SUMMONER_ID = '6304677' #おれ
#SUMMONER_ID = '6160658' #Rainさん
#SUMMONER_ID = '6179151' #スタンミさん
#SUMMONER_ID = '6313201' #みらいさん
#SUMMONER_ID = '6172666' #SPYGEAさん(だれ？)
#SUMMONER_ID = '6695493' #そにろじさん
#SUMMONER_ID = '8760255' #UGさん
#SUMMONER_ID = '7051645' #まゆりさん
#SUMMONER_ID = '6188121' #なぎさっちさん
#SUMMONER_ID = '6416807' #damさん
#SUMMONER_ID = '6470919' #yanyantkbさん
#SUMMONER_ID = '7731016' #すうさん

def generate_html(name)
  window_width=1920
  icon_width=(window_width*0.05).floor+1
  icon_height=111
  window_t_margin=122
  window_height=icon_height*5+window_t_margin
  
  keystone_names = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]
  mastery_list = CSV.read(File.expand_path(File.dirname($0)) + '/../data/mastery.csv') #配列の配列
  mastery_hash = mastery_list.inject({}){|h, elem| h[elem[0]] = elem[1]; h}
  keystone_masteries = keystone_names.inject({}){|h, elem| h[mastery_hash.key(elem)] = elem; h}
  
  summoner_json = APICaller.summoner_byname(name)
  return summoner_json if summoner_json.kind_of?(Fixnum)
  
  summoner_id = summoner_json["id"].to_s
  json = APICaller.activegame_byid(summoner_id)
  return json if json.kind_of?(Fixnum)
  
  buf=""
  buf += <<-EOS
    <html>
    <head>
    <!--<meta http-equiv="Refresh" content="30">-->
    <title>マスタリー</title>
    </head>
    <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
    <!-- arg : #{ARGV[0]}(#{summoner_id}) -->
    <!--
    last update : #{DateTime.now}
    -->
    <!--
    #{json}
    -->
    <table border=0 width="#{window_width}" height="#{window_height}" cellspacing="0" cellpadding="0">
    <tr height="#{window_t_margin}">
    <td width="#{icon_width}"></td>
    <td width="#{window_width-icon_width*2}"></td>
    <td width="#{icon_width}"></td></tr>
    <tr>
  EOS
  
  ins_icon_sides=28
  ins_l_margin=32
  ins_t_margin=15
  ins_v_margin=7
  
  [100,200].each{|teamId|
    buf += %!<td><table border=0 width="#{icon_width}" height="#{icon_height*5}" cellspacing="0" cellpadding="0">!
    json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
      part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
      part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
      l_json = APICaller.position_byid(elem["summonerId"])
      #return l_json if l_json.kind_of?(Fixnum)
      
      buf += <<-EOS
        <!--
        #{l_json}
        -->
        <tr height="#{ins_t_margin}">
        <td width="#{teamId == 100 ? ins_l_margin : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}"></td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}"></td>
        </tr>
        <tr height="#{ins_icon_sides}">
        <td width="#{teamId == 100 ? ins_l_margin : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}">
      EOS
      buf += <<-EOS if teamId == 100
        <img src=../img/#{l_json.nil? ? 'UNRANK' : l_json["tier"]+l_json["rank"]}.png width="#{ins_icon_sides}" height="#{ins_icon_sides}">
      EOS
      buf += <<-EOS
        </td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}">
      EOS
      buf += <<-EOS if teamId == 200
        <img src=../img/#{l_json.nil? ? 'UNRANK' : l_json["tier"]+l_json["rank"]}.png width="#{ins_icon_sides}" height="#{ins_icon_sides}">
      EOS
      buf += <<-EOS
        </td><td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}"></td>
        </tr>
        <tr height="#{ins_v_margin}">
        <td width="#{teamId == 100 ? ins_l_margin : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}"></td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}"></td>
        </tr>
        <tr height="#{ins_icon_sides}">
        <td width="#{teamId == 100 ? ins_l_margin : ins_icon_sides}">
      EOS
      buf += %!<img src="../img/#{part_keystone}.png" width="#{ins_icon_sides}" height="#{ins_icon_sides}">! if teamId == 200 && !part_keystone.nil?
      buf += <<-EOS
        </td><td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}"></td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}">
      EOS
      buf += %!<img src="../img/#{part_keystone}.png" width="#{ins_icon_sides}" height="#{ins_icon_sides}">! if teamId == 100 && !part_keystone.nil?
      buf += <<-EOS
        </td></tr>
        <tr height="#{icon_height - ins_t_margin - ins_v_margin - ins_icon_sides*2}">
        <td width="#{teamId == 100 ? ins_l_margin : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}"></td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}"></td>
        </tr>
      EOS
    }
    buf += %!</table></td>!
    buf += %!<td></td>! if teamId == 100
    sleep 0.5 #API制限緩和用
  }
  buf += %!</tr></table></body></html>!
  
  File.open(File.expand_path(File.dirname($0)).gsub("cgi-bin", "html/overlay/") + summoner_id + '.html', "w"){|f| f.puts buf}
  return summoner_id
end
