require 'rails_helper'

describe Api::MakeMove do
  before(:each) do
    @game = Game.new(player_x_name: 'Player 1', player_o_name: 'Player 2')
    @game.status_in_progress!
  end

  it 'should change the current symbol after valid move' do
    expect(@game.current_symbol).to eq 'x'
    Api::MakeMove.new(@game, 0, 'x').call
    expect(@game.current_symbol).to eq 'o'
  end

  it 'should not allow the first move by o' do
    expect(Api::MakeMove.new(@game, 0, 'o').call).to be false
  end

  it 'should not allow move position out of range' do
    expect(Api::MakeMove.new(@game, 10, 'x').call).to be false
  end

  it 'should not allow move without position or symbol specified' do
    expect(Api::MakeMove.new(@game, nil, 'x').call).to be false
    expect(Api::MakeMove.new(@game, 0, nil).call).to be false
  end

  it 'should not allow move if game status is not in_progress' do
    @game.status_canceled!
    expect(Api::MakeMove.new(@game, 0, 'x').call).to be false
  end

  it 'should check the winner after each move' do
    @game.update(current_symbol: 'o', board: ['o', 'o', nil, 'x', nil, nil, 'x', nil, 'x'])
    Api::MakeMove.new(@game, 2, 'o').call
    expect(@game.status_winner_o?).to be true
  end

  it 'should set tie if no winner and moves available' do
    @game.update(current_symbol: 'x', board: ['o', 'o', 'x', 'x', nil, 'o', 'o', 'x', 'x'])
    Api::MakeMove.new(@game, 4, 'x').call
    expect(@game.status_tie?).to be true
  end
end
