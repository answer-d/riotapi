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
  
  # arg : SN
  # ret : サモナー情報(summonerid, accountid, summonername等)
  def self.summoner_byname(name)
    @@logger.debug("summoner_byname(#{name}) start")

    if name.empty?
      e = RiotAPIException.new(0, "サモナーネームに何か入れて下さいよホンマ")
      @@logger.info("summoner name is empty. raise #{e}")
      raise e
    end
    
    uri_api = "/lol/summoner/v3/summoners/by-name/#{name}"
    @@logger.debug("uri_api : #{uri_api}")

    begin
      @@logger.debug("call get_json(#{@@uri_head + uri_api + @@uri_foot})")
      json = get_json(@@uri_head + uri_api + @@uri_foot)
      @@logger.debug("ret get_json(#{@@uri_head + uri_api + @@uri_foot}) => #{json}")
    rescue RiotAPIException => e
      @@logger.warn("RiotAPIException occured : #{e}")
      case e.code
      when 404
        @@logger.info("404 not found(SN : #{name})")
        e.msg += "<br>\nそんなサモナーネームはないと思います"
      else
        @@logger.error("unknown code : #{e.code}")
      end
      @@logger.warn("propagates #{e}")
      raise e
    end
    
    @@logger.debug("summoner_byname(#{name}) end => #{json}")
    return json
  end

  # arg : SID
  # ret : 進行中ゲーム情報
  def self.activegame_byid(id)
    uri_api = "/lol/spectator/v3/active-games/by-summoner/#{id}"
    
    begin
      json = get_json(@@uri_head + uri_api + @@uri_foot)
    rescue RiotAPIException => e
      case e.code
      when 404
        e.msg += "<br>\nゲーム中じゃ無いと思います、確認して再実行オナシャス(SID : #{id})"
      end
      raise e
    end

    return json
  end
  
  # arg : SID
  # ret : ランク(Tier, Division等)
  def self.position_byid(id)
    uri_api = "/lol/league/v3/positions/by-summoner/#{id}"
    
    begin
      json = get_json(@@uri_head + uri_api + @@uri_foot).at(0)
    rescue RiotAPIException => e
      raise e
    end

    return json
  end

  # arg : なし
  # ret : マスタリー情報(static)
  def self.mastery_static()
    uri_api = "/lol/static-data/v3/masteries"
    
    begin
      json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
    rescue RiotAPIException => e
      raise e
    end

    return json
  end
  
  # arg : なし
  # ret : チャンピオン情報(static)
  def self.champion_static()
    uri_api = "/lol/static-data/v3/champions"
    
    begin
      json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
    rescue RiotAPIException => e
      raise e
    end

    return json
  end
  
  # arg : URI(String)
  # ret : JSON(Array or Hash)
  # ret(error) : HTTPステータスコード(Fixnum)
  # URIからJSONをパースして返す感じ
  # 上の各メソッドから呼んで使う共通処理的なやつ
  def self.get_json(uri)
    uri = URI.parse URI.encode(uri)
    res = Net::HTTP.get_response(uri)
    
    if res.code != '200'
      code = res.code.to_i
      msg = "APIコールでエラー : #{uri}(#{code})"
      
      case code
      when 400
        msg += "<br>\nベリーバッドなリクエスト、おこです"
      when 403
        msg += "<br>\nAPIキーが切れてるかもしれない祭り。あんでぃーを怒れ"
      when 429
        msg += "<br>\nれーとりみっとです、加減してくださいお願いします何でもしますから(何でもするとは言っていない)"
      when 500
        msg += "<br>\nRiotAPI側のエラー。Rito plz"
      end
      
      raise RiotAPIException.new(code, msg)
    end
    
    json = JSON.load(res.body)
    return json
  end
end

