class CreateUrlAnalytics < ActiveRecord::Migration
  def change
    create_table :url_analytics do |t|
      t.text :json
      t.references :url_builder, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
