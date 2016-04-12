class CreateTestings < ActiveRecord::Migration
  def change
    create_table :testings do |t|
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end
