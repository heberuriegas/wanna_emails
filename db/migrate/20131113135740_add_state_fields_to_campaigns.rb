class AddStateFieldsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :starts_at, :datetime
    add_column :campaigns, :ends_at, :datetime
    add_column :campaigns, :state, :integer
    add_column :campaigns, :report, :text
  end
end
