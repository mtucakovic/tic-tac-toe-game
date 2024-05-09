class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "GameChannel:#{params[:id]}"
  end

  def unsubscribed
    game_id = params[:id].split('_').first.to_i
    if game_id.positive?
      game = Game.find(game_id)
      game.status_canceled! if game.status_waiting_for_second_player? || game.status_in_progress?

      Game::SYMBOLS.each do |s|
        ActionCable.server.broadcast "GameChannel:#{game.id}_#{s}", {
          message: { error: nil, game: Api::GameSerializer.new(game).attributes }.to_json
        }
      end
    end
  end
end
