class Api::GamesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :fetch_game, only: %i[show update]

  def show
    render json: { error: nil, game: game_response }, status: :ok if @game
  end

  def create
    if create_params[:name].present?
      @game = Api::JoinGame.new(create_params).call

      ActionCable.server.broadcast "GameChannel:#{@game.id}_#{@game.current_symbol}", {
        message: { error: nil, game: game_response }.to_json
      }

      render json: { error: nil, game: game_response }, status: :created
    else
      render json: { error: 'Invalid parameters', game: nil }, status: :unprocessable_entity
    end
  end

  def update
    if Api::MakeMove.new(@game, update_params[:position], update_params[:symbol]).call
      ActionCable.server.broadcast "GameChannel:#{@game.id}_#{@game.current_symbol}", {
        message: { error: nil, game: game_response }.to_json
      }

      render json: { error: nil, game: game_response }, status: :ok
    else
      render json: { error: 'Invalid move', game: game_response }, status: :unprocessable_entity
    end
  end

  private

  def game_response
    Api::GameSerializer.new(@game).attributes
  end

  def fetch_game
    @game = Game.find_by(id: params[:id])

    render json: { error: 'Not found' }, status: :not_found unless @game
  end

  def create_params
    params.permit(:name)
  end

  def update_params
    params.permit(:position, :symbol)
  end
end
