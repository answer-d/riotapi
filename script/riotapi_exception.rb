=begin
APIコール時の例外クラス
=end

class RiotAPIException < StandardError
  attr_accessor :code, :msg
  
  # arg[1] : HTTPステータスコード
  # arg[2] : メッセージ
  def initialize(code, msg)
    @code = code
    @msg = msg
  end

  def msg_to_html()
    return @msg.gsub("\n", "<br>\n")
  end
end
