class CreateCampaignsRecollections < ActiveRecord::Migration
  def change
    create_table :campaigns_recollections, :id => false do |t|
      t.references :recollection
      t.references :campaign
      t.primary_key [:campaign_id, :recollection_id]
    end

    add_index :campaigns_recollections, [:campaign_id, :recollection_id], unique: true, name: :index_campaigns_recollections
  end
end
