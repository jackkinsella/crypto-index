class ApplicationView < ActiveRecord::Base
  self.abstract_class = true

  def self.refresh
    Scenic.database.refresh_materialized_view(
      table_name, concurrently: true, cascade: false
    )
  end
end
