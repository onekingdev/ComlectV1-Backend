class AddDateToTimeLogs < ActiveRecord::Migration
  def change
    add_column :time_logs, :date, :date, default: nil
  end
end
