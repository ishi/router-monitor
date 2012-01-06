class AddActiveToStatisticValues < ActiveRecord::Migration
  def change
    add_column :statistic_values, :active, :boolean, :default => true
  end
end
