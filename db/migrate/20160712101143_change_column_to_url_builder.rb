class ChangeColumnToUrlBuilder < ActiveRecord::Migration
  def change
    change_column(:url_builders, :profile, :string) 
  end
end
