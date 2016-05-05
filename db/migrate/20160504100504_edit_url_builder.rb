class EditUrlBuilder < ActiveRecord::Migration
  def change
    add_column(:url_builders, :start_date, :datetime)
    add_column(:url_builders, :end_date, :datetime)
    remove_column(:url_builders , :medium)
  end
end
