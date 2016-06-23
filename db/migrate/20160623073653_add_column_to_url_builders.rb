class AddColumnToUrlBuilders < ActiveRecord::Migration
  def change
    add_column :url_builders, :profile, :integer
  end
end
