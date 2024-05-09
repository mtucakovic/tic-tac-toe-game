class Game < ApplicationRecord
  SYMBOLS = %w[x o].freeze
  BOARD_INDEXES = (0..8).freeze
  WINNING_COMBINATIONS = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], # across
    [0, 3, 6], [1, 4, 7], [2, 5, 8], # up / down
    [0, 4, 8], [2, 4, 6]             # diagonally
  ].freeze

  enum :status, {
    waiting_for_second_player: 0,
    in_progress: 1,
    winner_x: 2,
    winner_o: 3,
    tie: 4,
    canceled: 5
  }, prefix: true

  after_initialize :default_state

  private

  def default_state
    self.board ||= Array.new(9)
    self.current_symbol ||= SYMBOLS.first
  end
end
