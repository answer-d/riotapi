require 'net/http'
require 'uri'
require 'json'

class APICaller
  @@apikey = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
  @@uri_head = "https://jp1.api.riotgames.com"
  @@uri_foot = "?api_key=#{@@apikey}"

  def self.summoner_byname(name)
    uri_api = "/lol/summoner/v3/summoners/by-name/#{name}"
    json = get_json(@@uri_head + uri_api + @@uri_foot)
    return json
  end

  def self.activegame_byid(id)
    uri_api = "/lol/spectator/v3/active-games/by-summoner/#{id}"
    json = get_json(@@uri_head + uri_api + @@uri_foot)
    return json
  end
  
  def self.position_byid(id)
    uri_api = "/lol/league/v3/positions/by-summoner/#{id}"
    json = get_json(@@uri_head + uri_api + @@uri_foot).at(0)
    return json
  end

  def self.mastery_static()
    uri_api = "/lol/static-data/v3/masteries"
    json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
    return json
  end
  
  def self.champion_static()
    uri_api = "/lol/static-data/v3/champions"
    json = get_json(@@uri_head + uri_api + @@uri_foot + '&locale=ja_JP')
    return json
  end
  
  def self.get_json(uri)
    uri = URI.parse URI.encode(uri)
    res = Net::HTTP.get_response(uri)
    puts "APIが200以外で返った : #{uri}(#{res.code})" if res.code != '200'
    json = JSON.load(res.body)
    return json
  end
end

