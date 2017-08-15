require 'date'
require "#{File.expand_path(File.dirname($0))}/api_caller.rb"

hash = APICaller.position_byid("6304677")

buf = ""
buf += <<-EOS
  <html>
  <head>
  <meta http-equiv="Refresh" content="30">
  <title>レート</title>
  </head>
  <body topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
  <!--
  last update : #{DateTime.now}
  -->
  <table border=0 width="256" height="64" cellspacing="0" cellpadding="0">
  <tr><td width="64">
  <img src=./img/#{hash.nil? ? 'UNRANK' : hash["tier"]+hash["rank"]}.png width="64" height="64">
  </td><td>
  <b><font size="5" color="white">
    #{hash["tier"]} #{hash["rank"]}<br>
    #{hash["leaguePoints"]}LP
  </font></b>
  </td></tr>
  </table>
  </body>
  </html>
EOS

puts buf

