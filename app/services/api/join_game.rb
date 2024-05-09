class Api::JoinGame
  attr_accessor :name

  def initialize(game_params)
    @name = game_params.dig(:name)
  end

  def call
    game = Game.status_waiting_for_second_player.first

    return join_existing_game(game) if game

    game ||= Game.create(player_x_name: name)
  end

  private

  def join_existing_game(game)
    game.player_o_name = name
    game.status_in_progress!

    game
  end
end
