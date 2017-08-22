require_relative 'html_generator.rb'

begin
  puts HtmlGenerator.cur_rank('6304677')
  #puts HtmlGenerator.cur_rank('63')
rescue RiotAPIException => e
  STDERR.puts e.msg
  exit 0 #cronからメール来るのめんどい…
end

