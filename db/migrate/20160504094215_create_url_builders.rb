class CreateUrlBuilders < ActiveRecord::Migration
  def change
    create_table :url_builders do |t|
      t.references :user, index: true, foreign_key: true
      t.text :url
      t.string :source
      t.string :medium
      t.string :term
      t.string :content
      t.string :name

      t.timestamps null: false
    end
  end
end
