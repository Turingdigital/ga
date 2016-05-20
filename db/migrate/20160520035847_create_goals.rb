class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.references :user, index: true, foreign_key: true
      t.text :json

      t.timestamps null: false
    end
  end
end
