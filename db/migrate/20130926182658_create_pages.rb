class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :host
      t.string :uri

      t.timestamps
    end
  end
end
