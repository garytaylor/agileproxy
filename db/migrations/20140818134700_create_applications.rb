class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.integer :user_id  #The owner
      t.string :name      #The application name
      t.timestamps
    end
    add_index :applications, :user_id, :unique => false
  end
end