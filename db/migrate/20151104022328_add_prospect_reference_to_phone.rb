class AddProspectReferenceToPhone < ActiveRecord::Migration
  def change
    add_reference :phones, :prospect, index: true
  end
end
