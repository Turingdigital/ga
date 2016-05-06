class AddShortUrlToUrlBuilders < ActiveRecord::Migration
  def change
    add_column :url_builders, :short_url, :string
  end
end
