require 'rails_helper'

describe Api::JoinGame do
  it 'creates a new game if there are no players waiting' do
    game_params = { name: 'Player 1' }
    expect { Api::JoinGame.new(game_params).call }.to change { Game.count }.by(1)
    expect(Game.last.status_waiting_for_second_player?).to eq true
  end

  it 'joins and starts existing game if waiting for second player' do
    Game.create(player_x_name: 'Player 1')
    game_params = { name: 'Player 2' }
    expect { Api::JoinGame.new(game_params).call }.not_to(change { Game.count })
    expect(Game.last.status_in_progress?).to eq true
  end
end
