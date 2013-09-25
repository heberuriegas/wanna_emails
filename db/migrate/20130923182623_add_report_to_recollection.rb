class AddReportToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :report, :text
  end
end
