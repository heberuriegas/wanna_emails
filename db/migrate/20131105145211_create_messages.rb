class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :text
      t.references :project, index: true

      t.timestamps
    end
  end
end
