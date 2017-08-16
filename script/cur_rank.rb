require File.expand_path(File.dirname(__FILE__)) + "/html_generator.rb"

begin
  #puts HtmlGenerator.cur_rank('6304677')
  puts HtmlGenerator.cur_rank('6304677')
rescue RiotAPIException => e
  STDERR.puts e.msg
end

