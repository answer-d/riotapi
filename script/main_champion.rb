=begin
チャンプ一覧を標準出力に書く
=end

require_relative 'api_caller.rb'

json = APICaller.champion_static()
json["data"].each{|key,val| puts "#{val["id"]},#{val["name"]}"}

