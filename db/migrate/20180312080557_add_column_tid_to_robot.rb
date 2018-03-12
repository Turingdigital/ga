class AddColumnTidToRobot < ActiveRecord::Migration
  def change
    add_column :robots, :tid, :string
  end
end
