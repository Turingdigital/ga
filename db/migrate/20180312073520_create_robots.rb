class CreateRobots < ActiveRecord::Migration
  def change
    create_table :robots do |t|
      t.integer :count
      t.text :target
      t.string :title
      t.string :cs
      t.string :cm
      t.string :cn
      t.string :ul
      t.string :geoid
      t.string :sr
      t.string :vp
      t.text :ua

      t.timestamps null: false
    end
  end
end
