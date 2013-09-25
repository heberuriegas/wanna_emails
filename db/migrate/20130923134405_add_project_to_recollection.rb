class AddProjectToRecollection < ActiveRecord::Migration
  def change
    add_reference :recollections, :project, index: true
  end
end
