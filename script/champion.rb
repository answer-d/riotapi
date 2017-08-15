require "#{File.expand_path(File.dirname($0))}/api_caller.rb"

json = APICaller.champion_static()
json["data"].each{|key,val| puts "#{val["id"]},#{val["name"]}"}

