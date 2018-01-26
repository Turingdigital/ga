class CreateMatrixec11s < ActiveRecord::Migration
  def change
    create_table :matrixec11s do |t|
      t.string :date
      t.string :hour
      t.string :age
      t.integer :sessions
      t.integer :transactions
      t.float :revenue
      t.float :ct

      t.timestamps null: false
    end
  end
end
