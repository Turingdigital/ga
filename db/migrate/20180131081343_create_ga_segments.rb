class CreateGaSegments < ActiveRecord::Migration
  def change
    create_table :ga_segments do |t|
      t.string :name
      t.text :definition

      t.timestamps null: false
    end
  end
end
