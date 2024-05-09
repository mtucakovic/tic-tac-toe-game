class Api::MakeMove
  attr_accessor :game, :position, :symbol

  def initialize(game, position, symbol)
    @game = game
    @position = position.blank? ? nil : position.to_i
    @symbol = symbol.blank? ? nil : symbol.downcase
  end

  def call
    if Api::GamePolicy.new(game).move_allowed?(position, symbol)
      game.board[position] = symbol
      check_winner
      switch_player
      game.save
    else
      false
    end
  end

  private

  def check_winner
    Game::WINNING_COMBINATIONS.each do |combination|
      next unless combination.all? { |pos| game.board[pos] == symbol }

      return game.send("status_winner_#{symbol}!".downcase)
    end

    game.status_tie! if game.board.compact_blank.count == 9
  end

  def switch_player
    game.current_symbol = game.current_symbol == 'x' ? 'o' : 'x'
  end
end
