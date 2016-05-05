class CreateFoos < ActiveRecord::Migration
  def change
    create_table :foos do |t|
      t.string :title
      t.datetime :start_date

      t.timestamps null: false
    end
  end
end
