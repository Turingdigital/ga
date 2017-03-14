class AddTwohourToUrlbuilder < ActiveRecord::Migration
  def change
    add_column :url_builders, :twohour, :integer
  end
end
