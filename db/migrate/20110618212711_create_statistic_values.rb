class CreateStatisticValues < ActiveRecord::Migration
  def change
    create_table :statistic_values do |t|
      t.string :name
      t.string :print_name
      t.integer :interval
      t.text :script

      t.timestamps
    end
  end
end
