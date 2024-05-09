class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :player_x_name
      t.string :player_o_name
      t.string :board, array: true
      t.string :current_symbol
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
