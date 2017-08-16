=begin
Riot APIをコールしてjsonを返すメソッドの入ったクラス
各メソッドは特異メソッドとして実装
=end

require 'net/http'
require 'uri'
require 'json'

class APICaller
  # 固定値軍団
  @@apikey = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
  @@uri_head = "https://jp1.api.riotgames.com"
  @@uri_foot = "?api_key=#{@@apikey}"

  # arg : SN
  # ret : サモナー情報(summonerid, accountid, summonername等)
  def self.summoner_byname(name)
    uri_api = "/lol/summoner/v3/summoners/by-name/#{name}"
    json = get_json(@@uri_head + uri_api + @@uri_foot)
    return json
  end

  # arg : SID
  # ret : 進行中ゲーム情報
  def self.activegame_byid(id)
    uri_api = "/lol/spectator/v3/active-games/by-summoner/#{id}"
    json = get_json(@@uri_head + uri_api + @@uri_foot)
    return json
  end
  
  # arg : SID
  # ret : ランク(Tier, Division等)
  def self.position_byid(id)
    uri_api = "/lol/league/v3/positions/by-summoner/#{id}"
    json = get_json(@@uri_head + uri_api + @@uri_foot).at(0)
    return json
  end

  # arg : なし
  # ret : マスタリー情報(static)
  def self.mastery_static()
    uri_api = "/lol/static-data/v3/masteries"
    json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
    return json
  end
  
  # arg : なし
  # ret : チャンピオン情報(static)
  def self.champion_static()
    uri_api = "/lol/static-data/v3/champions"
    json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
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
    (puts "APIコールでエラー : #{uri}(#{res.code})"; return res.code.to_i) if res.code != '200'
    json = JSON.load(res.body)
    return json
  end
end

