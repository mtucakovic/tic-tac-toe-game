module Api
  class GameSerializer
    def initialize(game)
      @game = game
    end

    attr_accessor :game

    def attributes
      {
        id: game.id,
        player_x_name: game.player_x_name,
        player_o_name: game.player_o_name,
        status: game.status,
        board: game.board,
        current_symbol: game.current_symbol,
        winner_name: winner_name
      }
    end

    private

    def winner_name
      case game.status
      when 'winner_x'
        game.player_x_name
      when 'winner_o'
        game.player_o_name
      end
    end
  end
end
