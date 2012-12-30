class CreateDevices < ActiveRecord::Migration
  def up
  	create_table :devices do |t|
      t.string  :device_name
      t.string  :device_code
      t.integer :user_id
    end
  end

  def down
  	drop_table :devices;
  end
end
