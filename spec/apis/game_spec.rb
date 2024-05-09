require 'rails_helper'

describe Api::GamesController do
  describe 'POST /api/games', type: :request do
    it 'requires player name to create a game' do
      post '/api/games', params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      game_response = JSON.parse(response.body)
      expect(game_response['error']).not_to eq(nil)
    end

    it 'creates and returns a game with waiting_for_second_player status' do
      post '/api/games', params: { name: 'Player 1' }

      expect(response).to have_http_status(:created)
      game_response = JSON.parse(response.body)['game']
      expect(game_response['player_x_name']).to eq('Player 1')
      expect(game_response['player_o_name']).to eq(nil)
      expect(game_response['status']).to eq('waiting_for_second_player')
      expect(game_response['board']).to eq([nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(game_response['current_symbol']).to eq('x')
      expect(game_response['winner_name']).to eq(nil)
    end

    context 'when 1 user waiting' do
      let!(:game) { FactoryBot.create(:game, player_x_name: 'Player 1') }

      it 'creates and returns a game with in_progress status' do
        post '/api/games', params: { name: 'Player 2' }

        expect(response).to have_http_status(:created)
        game_response = JSON.parse(response.body)['game']
        expect(game_response['player_x_name']).to eq('Player 1')
        expect(game_response['player_o_name']).to eq('Player 2')
        expect(game_response['status']).to eq('in_progress')
        expect(game_response['board']).to eq([nil, nil, nil, nil, nil, nil, nil, nil, nil])
        expect(game_response['current_symbol']).to eq('x')
        expect(game_response['winner_name']).to eq(nil)
      end
    end
  end

  describe 'PATCH /api/games/GAME_ID', type: :request do
    let!(:game) do
      FactoryBot.create(:game, player_x_name: 'Player 1', player_o_name: 'Player 2', status: 'in_progress')
    end

    it 'requires position and symbol to make a move' do
      patch "/api/games/#{game.id}", params: {}

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'allows only the expected symbol and position range for the next move' do
      patch "/api/games/#{game.id}", params: { symbol: 'o', position: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).not_to eq(nil)

      patch "/api/games/#{game.id}", params: { symbol: 'x', position: 10 }
      expect(response).to have_http_status(:unprocessable_entity)

      patch "/api/games/#{game.id}", params: { symbol: 'x', position: 0 }
      expect(response).to have_http_status(:ok)
    end

    it 'does not allow move to an occupied position' do
      game.update(board: ['x', 'o', nil, nil, nil, nil, nil, nil, nil])

      patch "/api/games/#{game.id}", params: { symbol: 'x', position: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'updates board status and current_player after a valid move' do
      patch "/api/games/#{game.id}", params: { symbol: 'x', position: 3 }
      expect(response).to have_http_status(:ok)
      game_response = JSON.parse(response.body)['game']
      expect(game_response['status']).to eq('in_progress')
      expect(game_response['board']).to eq([nil, nil, nil, 'x', nil, nil, nil, nil, nil])
      expect(game_response['current_symbol']).to eq('o')
    end

    it 'updates tie status if no winner and no moves left' do
      game.update(current_symbol: 'x', board: ['o', 'o', 'x', 'x', nil, 'o', 'o', 'x', 'x'])

      patch "/api/games/#{game.id}", params: { symbol: 'x', position: 4 }
      expect(response).to have_http_status(:ok)
      game_response = JSON.parse(response.body)['game']
      expect(game_response['status']).to eq('tie')
      expect(game_response['board']).to eq(%w[o o x x x o o x x])
      expect(game_response['winner_name']).to eq(nil)
    end

    it 'updates winner status' do
      game.update(current_symbol: 'o', board: ['o', 'o', nil, 'x', nil, nil, 'x', nil, 'x'])

      patch "/api/games/#{game.id}", params: { symbol: 'o', position: 2 }
      expect(response).to have_http_status(:ok)
      game_response = JSON.parse(response.body)['game']
      expect(game_response['status']).to eq('winner_o')
      expect(game_response['board']).to eq(['o', 'o', 'o', 'x', nil, nil, 'x', nil, 'x'])
      expect(game_response['winner_name']).to eq('Player 2')
    end
  end
end
