=begin
HTML生成器
=end

require 'date'
require 'csv'
require_relative 'api_caller.rb'

class HtmlGenerator
  # 固定値軍団
  @@basedir = File.expand_path(File.dirname(__FILE__))
  @@basename = File.basename(__FILE__, ".rb")
  @@conf = YAML.load_file("#{@@basedir}/../conf/app.yml")
  
  @@logger = Logger.new("#{@@basedir}/../log/#{File.basename($0, ".rb")}.log")
  @@logger.level = eval @@conf["logger"]["log_level"]
  
  # 現在のランクを表示するやつのラッパ
  def self.wr_cur_rank(name)
    @@logger.info("#{@@basename} : wr_cur_rank(#{name}) start")
    
    begin
      @@logger.debug("#{@@basename} : call APICaller.summoner_byname(#{name})")
      summoner_json = APICaller.summoner_byname(name)
      @@logger.debug("#{@@basename} : ret APICaller.summoner_byname(#{name})")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    summoner_id = summoner_json["id"]
    @@logger.info("#{@@basename} : #{name}'s summoner_id is #{summoner_id}")
    
    buf = ""
    buf += <<-EOS
      <html>
      <head>
      </head>
      <body>
      <p>
      サモナーネーム : #{name}
      </p>
      <h2><a href="http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/app/main_rank.rb?id=#{summoner_id}" target="blank">
      http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/app/main_rank.rb?id=#{summoner_id}</a></h2>
      <h3>設定方法</h3>
      <p>
      ★なんかかく
      </p>
      <h3>注意</h3>
      <p>
      ★なんかなんかかく
      </p>
      <hr>
      <p>
      <a href="/rank.html">戻りたい</a>
      </p>
      </body>
      </html>
    EOS
    
    @@logger.info("#{@@basename} : wr_cur_rank(#{name}) end => #{buf}")
    return buf
  end
  
  # 現在のランクを表示
  def self.cur_rank(summoner_id)
    @@logger.info("#{@@basename} : cur_rank(#{summoner_id}) start")
    
    refresh_rate = '30' #秒
    window_width = '256' #px
    window_height = '64' #px
    icon_sides = window_height
    font_options = 'size="5" color="white"'

    begin
      @@logger.debug("#{@@basename} : call APICaller.position_byid(#{summoner_id})")
      hash = APICaller.position_byid(summoner_id)
      @@logger.debug("#{@@basename} : ret APICaller.position_byid(#{summoner_id})")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    buf = ""
    buf += <<-EOS
      <html>
      <head>
      <meta http-equiv="Refresh" content="#{refresh_rate}">
      <meta http-equiv="Pragma" content="no-cache">
      <meta http-equiv="Cache-Control" content="no-cache">
      <meta http-equiv="Expires" content="0">
      </head>
      <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
      <!-- last update : #{DateTime.now} -->
      <table border=0 width="#{window_width}" height="#{window_height}" cellspacing="0" cellpadding="0">
      <tr><td width="#{icon_sides}">
      <img src=../img/#{hash.nil? ? 'UNRANK' : hash["tier"]+hash["rank"]}.png width="#{icon_sides}" height="#{icon_sides}">
      </td><td>
      <b><font #{font_options}>
      #{hash["tier"]} #{hash["rank"]}<br>
      #{hash["leaguePoints"]}LP
      #{"&nbsp;" + hash["miniSeries"]["progress"] if hash["leaguePoints"] == 100}
      </font></b>
      </td></tr>
      </table>
      </body>
      </html>
    EOS
    
    @@logger.info("#{@@basename} : cur_rank(#{summoner_id}) end => #{buf}")
    return buf
  end

  # キーストーンマスタリーを表示するやつのラッパ
  def self.wr_cur_keystones(name, show_position)
    @@logger.info("#{@@basename} : wr_cur_keystones(#{name}, #{show_position}) start")

    begin
      @@logger.debug("#{@@basename} : call APICaller.summoner_byname(#{name})")
      summoner_json = APICaller.summoner_byname(name)
      @@logger.debug("#{@@basename} : ret APICaller.summoner_byname(#{name})")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end

    summoner_id = summoner_json["id"]
    @@logger.info("#{@@basename} : #{name}'s summoner_id is #{summoner_id}")

    buf = ""
    buf += <<-EOS
      <html>
      <head>
      </head>
      <body>
      <p>
      サモナーネーム : #{name}<br>
      ランク表示するか : #{show_position}
      </p>
      <h2><a href="http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/app/main_keystones.rb?id=#{summoner_id}&show_position=#{show_position}" target="blank">
      http://ec2-54-149-199-29.us-west-2.compute.amazonaws.com/app/main_keystones.rb?id=#{summoner_id}&show_position=#{show_position}</a></h2>
      <h3>設定方法</h3>
      <p>
      ★なんかかく
      </p>
      <h3>注意</h3>
      <p>
      ★なんかなんかかく
      </p>
      <hr>
      <p>
      <a href="/keystone.html">戻りたい</a>
      </p>
      </body>
      </html>
    EOS

    @@logger.info("#{@@basename} : wr_cur_keystones(#{name}, #{show_position}) end => #{buf}")
    return buf
  end
  
  # キーストーンマスタリーを表示
  def self.cur_keystones(id, show_position)
    @@logger.info("#{@@basename} : cur_keystones(#{id}, #{show_position}) start")
    
    window_width=1920 #全体の横幅
    icon_width=(window_width*0.05).floor+1 #チャンピオン情報の横幅
    icon_height=111 #チャンピオン情報の縦幅(チャンピオン毎)
    window_t_margin=122 #全体の上側マージン
    window_height=icon_height*5+window_t_margin #全体の縦幅(1080じゃない、下が余る)
    ins_icon_sides=28 # マスタリー・ランクアイコンの一辺
    ins_l_margin=32 # サモスペ-ランク情報の間のマージン
    ins_t_margin=15 # 上側マージン
    ins_v_margin=7 # 間マージン

    # サモナーIDから進行中ゲーム情報のjsonを引っ張る
    summoner_id = id.to_i
    begin
      @@logger.debug("#{@@basename} : call APICaller.activegame_byid(#{summoner_id})")
      json = APICaller.activegame_byid(summoner_id)
      @@logger.debug("#{@@basename} : ret APICaller.activegame_byid(#{summoner_id})")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      case e.code
      when 404
        @@logger.info("#{@@basename} : activegame not found. returns standby html.")
      end
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end

    # キーストーンマスタリーの一覧をハッシュ化
    keystone_names = ["死神の残り火","雷帝の号令","岩界の盟約","嵐乗りの勇躍","巨人の勇気","風詠みの祝福","戦いの律動","不死者の握撃","渇欲の戦神"]
    mastery_list = CSV.read(File.expand_path(File.dirname(__FILE__)) + '/../data/mastery.csv') #配列の配列
    mastery_hash = mastery_list.inject({}){|h, elem| h[elem[0]] = elem[1]; h} #ハッシュ化
    keystone_masteries = keystone_names.inject({}){|h, elem| h[mastery_hash.key(elem)] = elem; h} #キーストーンだけ抜き出し
    @@logger.debug("#{@@basename} : keystone_masteries=#{keystone_masteries}")
    
    # HTML生成
    buf=""
    buf += <<-EOS
      <html>
      <head>
      <!-- last update : #{DateTime.now} -->
      </head>
      <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
      <table border=0 width="#{window_width}" height="#{window_height}" cellspacing="0" cellpadding="0">
      <tr height="#{window_t_margin}">
      <td width="#{icon_width}"></td>
      <td width="#{window_width-icon_width*2}"></td>
      <td width="#{icon_width}"></td></tr>
      <tr>
    EOS
    
    # サモナー毎に繰り返すところ
    img_options = %!width="#{ins_icon_sides}" height="#{ins_icon_sides}"!
    [100,200].each{|teamId|
      @@logger.debug("#{@@basename} : loop for teamId=#{teamId} start")
      buf += %!<td><table border=0 width="#{icon_width}" height="#{icon_height*5}" cellspacing="0" cellpadding="0">!
      json["participants"].select{|elem| elem["teamId"] == teamId}.each{|elem|
        @@logger.debug("#{@@basename} : loop for participant=#{elem["summonerName"]} - #{elem["summonerId"]} start")
        part_masteries = elem["masteries"].map{|hash| hash["masteryId"].to_s}
        part_keystone = part_masteries.find{|i| keystone_masteries.keys.include? i}
        @@logger.debug("#{@@basename} : part_keystone=#{part_keystone}")
        
        # ランク情報引っ張る部分
        if show_position
          begin
            @@logger.debug("#{@@basename} : call APICaller.position_byid(#{elem["summonerId"]})")
            l_json = APICaller.position_byid(elem["summonerId"])
            @@logger.debug("#{@@basename} : ret APICaller.position_byid(#{elem["summonerId"]})")
          rescue RiotAPIException => e
            @@logger.warn("#{@@basename} : #{e} occured")
            e.msg += "\nランク情報を引くのに失敗したンゴ…(#{elem["summonerName"]} - #{elem["summonerId"]})"
            @@logger.warn("#{@@basename} : propagates #{e}")
            raise e
          end

          img_rank = %!../img/#{l_json.nil? ? "UNRANK" : l_json["tier"]+l_json["rank"]}.png!
          @@logger.debug("#{@@basename} : img_rank=#{img_rank}")
        end

        img_keystone = %!../img/#{part_keystone}.png!
        @@logger.debug("#{@@basename} : img_keystone=#{img_keystone}")

        buf += <<-EOS
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
        buf += %!<img src="#{img_rank}" #{img_options}>! if show_position && teamId == 100
        buf += <<-EOS
          </td>
          <td width="#{teamId == 100 ? icon_width - ins_l_margin - ins_icon_sides*2 : ins_icon_sides}">
        EOS
        buf += %!<img src=#{img_rank} #{img_options}>! if show_position && teamId == 200
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
        @@logger.debug("#{@@basename} : loop for participant=#{elem["summonerName"]} - #{elem["summonerId"]} end")
      }
      buf += %!</table></td>!
      buf += %!<td></td>! if teamId == 100
      sleep 0.2 #API制限緩和用
      @@logger.debug("#{@@basename} : loop for teamId=#{teamId} end")
    }
    buf += %!</tr></table></body></html>!
    
    @@logger.info("#{@@basename} : cur_keystones(#{id}, #{show_position}) end => #{buf}")
    return buf
  end
  
  # CGI用ヘッダ
  def self.cgi_header()
    return <<-EOS
Content-type: text/html

    EOS
  end
end

