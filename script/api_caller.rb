=begin
Riot APIをコールしてjsonを返すメソッドの入ったクラス
各メソッドは特異メソッドとして実装
=end

require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'logger'
require_relative 'riotapi_exception.rb'

class APICaller
  # 固定値軍団
  @@basedir = File.expand_path(File.dirname(__FILE__))
  @@basename = File.basename(__FILE__, ".rb")
  @@conf = YAML.load_file("#{@@basedir}/../conf/app.yml")

  @@apikey = @@conf["api_key"]
  @@uri_head = "https://jp1.api.riotgames.com"
  @@uri_foot = "?api_key=#{@@apikey}"
  
  @@logger = Logger.new("#{@@basedir}/../log/#{File.basename($0, ".rb")}.log")
  @@logger.level = eval @@conf["logger"]["log_level"]
  
  # arg : SN
  # ret : サモナー情報(summonerid, accountid, summonername等)
  def self.summoner_byname(name)
    @@logger.info("#{@@basename} : summoner_byname(#{name}) start")
    
    if name.empty?
      e = RiotAPIException.new(0, "サモナーネームに何か入れて下さいよホンマ")
      @@logger.info("#{@@basename} : summoner name is empty. raise #{e}")
      raise e
    end
    
    uri_api = "/lol/summoner/v3/summoners/by-name/#{name}"
    @@logger.debug("#{@@basename} : uri_api : #{uri_api}")
    
    begin
      @@logger.debug("#{@@basename} : call get_json(#{@@uri_head + uri_api + @@uri_foot})")
      json = get_json(@@uri_head + uri_api + @@uri_foot)
      @@logger.debug("#{@@basename} : ret get_json(#{@@uri_head + uri_api + @@uri_foot}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      case e.code
      when 401
        @@logger.error("#{@@basename} : 401 Unauorized(SN : #{name})")
        e.msg += "\nAPIキーが切れているかもしれません？あんでぃーをおこ"
      when 404
        @@logger.info("#{@@basename} : 404 not found(SN : #{name})")
        e.msg += "\nそんなサモナーネームはないと思います"
      else
        @@logger.error("#{@@basename} : unknown code : #{e.code}")
      end
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    @@logger.info("#{@@basename} : summoner_byname(#{name}) end => #{json}")
    return json
  end

  # arg : SID
  # ret : 進行中ゲーム情報
  def self.activegame_byid(id)
    @@logger.info("#{@@basename} : activegame_byid(#{id}) start")
    uri_api = "/lol/spectator/v3/active-games/by-summoner/#{id}"
    
    begin
      @@logger.debug("#{@@basename} : call get_json(#{@@uri_head + uri_api + @@uri_foot})")
      json = get_json(@@uri_head + uri_api + @@uri_foot)
      @@logger.debug("#{@@basename} : ret get_json(#{@@uri_head + uri_api + @@uri_foot}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      case e.code
      when 404
        @@logger.info("#{@@basename} : 404 not found(id : #{id})")
        e.msg += "\nゲーム中じゃ無いと思います、確認して再実行オナシャス(SID : #{id})"
      end
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    @@logger.info("#{@@basename} : activegame_byid(#{id}) end => #{json}")
    return json
  end
  
  # arg : SID
  # ret : ランク(Tier, Division等)
  def self.position_byid(id)
    @@logger.info("#{@@basename} : position_byid(#{id}) start")
    uri_api = "/lol/league/v3/positions/by-summoner/#{id}"
    
    begin
      @@logger.debug("#{@@basename} : call get_json(#{@@uri_head + uri_api + @@uri_foot})")
      json = get_json(@@uri_head + uri_api + @@uri_foot).at(0)
      @@logger.debug("#{@@basename} : ret get_json(#{@@uri_head + uri_api + @@uri_foot}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    @@logger.info("#{@@basename} : position_byid(#{id}) end => #{json}")
    return json
  end

  # arg : なし
  # ret : マスタリー情報(static)
  def self.mastery_static()
    @@logger.info("#{@@basename} : mastery_static() start")
    uri_api = "/lol/static-data/v3/masteries"
    
    begin
      @@logger.debug("#{@@basename} : call get_json(#{@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP'})")
      json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
      @@logger.debug("#{@@basename} : ret get_json(#{@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP'}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    @@logger.info("#{@@basename} : mastery_static() end => #{json}")
    return json
  end
  
  # arg : なし
  # ret : チャンピオン情報(static)
  def self.champion_static()
    @@logger.info("#{@@basename} : champion_static() start")
    uri_api = "/lol/static-data/v3/champions"
    
    begin
      @@logger.debug("#{@@basename} : call get_json(#{@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP'})")
      json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
      @@logger.debug("#{@@basename} : ret get_json(#{@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP'}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("#{@@basename} : #{e} occured")
      @@logger.warn("#{@@basename} : propagates #{e}")
      raise e
    end
    
    @@logger.info("#{@@basename} : champion_static() end => #{json}")
    return json
  end
  
  # arg : URI(String)
  # ret : JSON(Array or Hash)
  # ret(error) : HTTPステータスコード(Fixnum)
  # URIからJSONをパースして返す感じ
  # 上の各メソッドから呼んで使う共通処理的なやつ
  def self.get_json(uri)
    @@logger.info("#{@@basename} : get_json(#{uri}) start")
    uri = URI.parse URI.encode(uri)
    res = Net::HTTP.get_response(uri)
    
    if res.code != '200'
      @@logger.warn("#{@@basename} : res.code is #{res.code}")
      code = res.code.to_i
      msg = "APIコールでエラー : #{code}"
      
      case code
      when 400
        msg += "\nベリーバッドなリクエスト、おこです"
      when 401
        msg += "\nAPIキーが切れてるかもしれない祭り。あんでぃーを怒れ"
      when 429
        msg += "\nれーとりみっとです、加減してくださいお願いします何でもしますから(何でもするとは言っていない)"
      when 500
        msg += "\nRiotAPI側のエラー、Rito plz"
      end
      
      e = RiotAPIException.new(code, msg)
      @@logger.warn("#{@@basename} : raise #{e}")
      raise e
    end
    @@logger.debug("#{@@basename} : res.code is 200")
    
    json = JSON.load(res.body)
    
    #@@logger.info("#{@@basename} : get_json(#{uri}) end => #{json}")
    @@logger.info("#{@@basename} : get_json(#{uri}) end")
    return json
  end
end
