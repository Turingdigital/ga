class AddIndexToUrlBuilders < ActiveRecord::Migration
  def change
    add_index :url_builders, :profile
  end
end
