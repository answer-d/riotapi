require "#{File.expand_path(File.dirname($0))}/api_caller.rb"

json = APICaller.mastery_static()
json["data"].each{|key,val| puts "#{key},#{val["name"]}"}

