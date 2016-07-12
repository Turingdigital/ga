class CreateGaData < ActiveRecord::Migration
  def change
    create_table :ga_data do |t|
      t.references :ga_label, index: true, foreign_key: true
      t.string :profile
      t.text :json

      t.timestamps null: false
    end
    add_index :ga_data, :profile
  end
end
