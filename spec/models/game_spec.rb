require 'rails_helper'

describe Game, type: :model do
  it 'predefines game status, empty board array and current symbol' do
    game = Game.new

    expect(game.status).to eq 'waiting_for_second_player'
    expect(game.board).to eq [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    expect(game.current_symbol).to eq 'x'
  end
end
