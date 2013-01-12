class CreateProjects < ActiveRecord::Migration
  def up
  	create_table :projects do |t|
      t.string  :name
      t.string  :description
      t.integer :user_id
    end
  end

  def down
  	drop_table :projects
  end
end
