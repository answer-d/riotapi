=begin
マスタリー一覧を標準出力に書く
=end

require "#{File.expand_path(File.dirname(__FILE__))}/api_caller.rb"

json = APICaller.mastery_static()
json["data"].each{|key,val| puts "#{key},#{val["name"]}"}

