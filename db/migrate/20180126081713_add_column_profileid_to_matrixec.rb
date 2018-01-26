class AddColumnProfileidToMatrixec < ActiveRecord::Migration
  def change
    add_column :matrixec11s, :profileid, :string
    add_index :matrixec11s, :profileid
  end
end
