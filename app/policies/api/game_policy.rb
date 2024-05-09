class Api::GamePolicy
  attr_accessor :game

  def initialize(game)
    @game = game
  end

  def move_allowed?(position, symbol)
    return false if position.blank? || symbol.blank?
    return false unless game.status_in_progress?
    return false if game.current_symbol.downcase != symbol.downcase
    return false if game.board[position]
    return false unless position.in? Game::BOARD_INDEXES

    true
  end
end
