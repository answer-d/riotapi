# サモナー名とIDをリスト化する

require 'net/http'
require 'uri'
require 'json'

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/summoner/v3/summoners/by-name/'
URI_FOOT = "?api_key=#{APIKEY}"
SUMMONERS = "あんでぃー"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{SUMMONERS}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
hash = JSON.load(res.body)

puts "#{hash["name"]},#{hash["id"]},#{hash["accountId"]}"

