# サモナー名とIDをリスト化する

require 'net/http'
require 'uri'
require 'json'

APIKEY = 'RGAPI-ba4d7259-f0ca-4d35-85ad-64f70f1739a0'
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/summoner/v3/summoners/by-name/'
URI_FOOT = "?api_key=#{APIKEY}"
SUMMONERS = "あんでぃー"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{SUMMONERS}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
hash = JSON.load(res.body)

puts "#{hash["name"]},#{hash["id"]},#{hash["accountId"]}"

