class AddProspectToEmail < ActiveRecord::Migration
  def change
    create_table :emails_prospects do |t|
      t.references :email, index: true
      t.references :prospect, index: true
    end

    add_index :emails_prospects, [:email_id, :prospect_id], unique: true
  end
end
