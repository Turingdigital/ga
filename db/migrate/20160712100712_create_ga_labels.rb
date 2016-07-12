class CreateGaLabels < ActiveRecord::Migration
  def change
    create_table :ga_labels do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
