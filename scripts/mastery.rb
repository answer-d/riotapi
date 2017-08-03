# 日次実行
# マスタリー一覧化してidと名前を紐付ける

require 'net/http'
require 'uri'
require 'json'

APIKEY = File.open(File.expand_path(File.dirname($0)) + '/../conf/APIKEY').read.chomp
URI_HEAD = 'https://jp1.api.riotgames.com'
URI_API = '/lol/static-data/v3/masteries'
URI_FOOT = "?api_key=#{APIKEY}&locale=ja_JP"

uri = URI.parse URI.encode("#{URI_HEAD}#{URI_API}#{URI_FOOT}")
res = Net::HTTP.get_response(uri)
json = JSON.load(res.body)

json["data"].each{|key,val|
  puts "#{key},#{val["name"]}"
}

