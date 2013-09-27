class ChangeUriInPages < ActiveRecord::Migration
  def up
    change_column :pages, :uri, :text
  end

  def down
    change_column :pages, :uri, :string
  end
end
