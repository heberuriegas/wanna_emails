class AddPostedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :posted, :boolean, default: false
  end
end
