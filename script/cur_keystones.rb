=begin
マスタリーをいい感じに表示するブラウザソース生成器本体
メソッド定義だけなのでCGIから呼んで使う
正常処理すると../html/overlay配下に「サモナーID.html」としてhtmlファイルを吐き出す
動作確認は1920*1080のみ
=end

require 'csv'
require "#{File.expand_path(File.dirname(__FILE__))}/api_caller.rb"

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

# arg : サモナーネーム
# ret : サモナーID
# ret(error) : HTTPステータスコード(200以外)
def generate_html(name)
  window_width=1920 #全体の横幅
  icon_width=(window_width*0.05).floor+1 #チャンピオン情報の横幅
  icon_height=111 #チャンピオン情報の縦幅(チャンピオン毎)
  window_t_margin=122 #全体の上側マージン
  window_height=icon_height*5+window_t_margin #全体の縦幅(1080じゃない、下が余る)
  ins_icon_sides=28 # マスタリー・ランクアイコンの一辺
  ins_l_margin=32 # サモスペ-ランク情報の間のマージン
  ins_t_margin=15 # 上側マージン
  ins_v_margin=7 # 間マージン
  
  # キーストーンマスタリーの一覧をハッシュ化
  keystone_names = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]
  mastery_list = CSV.read(File.expand_path(File.dirname(__FILE__)) + '/../data/mastery.csv') #配列の配列
  mastery_hash = mastery_list.inject({}){|h, elem| h[elem[0]] = elem[1]; h} #ハッシュ化
  keystone_masteries = keystone_names.inject({}){|h, elem| h[mastery_hash.key(elem)] = elem; h} #キーストーンだけ抜き出し
  
  # サモナーネームからサモナーIDを引っ張る
  summoner_json = APICaller.summoner_byname(name)
  return summoner_json if summoner_json.kind_of?(Fixnum)
  summoner_id = summoner_json["id"]

  # サモナーIDから進行中ゲーム情報のjsonを引っ張る
  json = APICaller.activegame_byid(summoner_id)
  return json if json.kind_of?(Fixnum)
  
  # HTML生成
  buf=""
  buf += <<-EOS
    <html>
    <head>
    <title>マスタリー</title>
    </head>
    <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
    <!-- arg : #{name}(#{summoner_id}) -->
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
  
  img_options = %!width="#{ins_icon_sides}" height="#{ins_icon_sides}"!
  [100,200].each{|teamId|
    buf += %!<td><table border=0 width="#{icon_width}" height="#{icon_height*5}" cellspacing="0" cellpadding="0">!
    json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
      part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
      part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
      l_json = APICaller.position_byid(elem["summonerId"])
      #return l_json if l_json.kind_of?(Fixnum)
      
      img_rank = %!../img/#{l_json.nil? ? "UNRANK" : l_json["tier"]+l_json["rank"]}.png!
      img_keystone = %!../img/#{part_keystone}.png!

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
        <img src="#{img_rank}" #{img_options}>
      EOS
      buf += <<-EOS
        </td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}">
      EOS
      buf += <<-EOS if teamId == 200
        <img src=#{img_rank} #{img_options}>
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
      buf += %!<img src="#{img_keystone}" #{img_options}>! if teamId == 200 && !part_keystone.nil?
      buf += <<-EOS
        </td><td width="#{teamId == 100 ? ins_icon_sides : icon_width - ins_l_margin - ins_icon_sides*2}"></td>
        <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}"></td>
        <td width="#{teamId == 100 ? ins_icon_sides : ins_l_margin}">
      EOS
      buf += %!<img src="#{img_keystone}" #{img_options}>! if teamId == 100 && !part_keystone.nil?
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
  
  # ファイル書き出し
  # overlayフォルダはapacheユーザに書き込み権限があること
  File.open(File.expand_path(File.dirname(__FILE__)).gsub("script", "html/overlay/") + summoner_id.to_s + '.html', "w"){|f|
    f.puts buf
  }

  return summoner_id
end
