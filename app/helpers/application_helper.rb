module ApplicationHelper

  def build_title(winner)
    if winner.kind_of?(Array) && winner.size == 2
      "This is a draw!"
    else
      "#{winner} Wins!!!"
    end
  end
end
