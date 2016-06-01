class AddIndexUrlBuilders < ActiveRecord::Migration
  def change
    add_index(:url_builders, :start_date)
    add_index(:url_builders, :end_date)
  end
end
