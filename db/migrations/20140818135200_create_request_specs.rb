class CreateRequestSpecs < ActiveRecord::Migration
  def change
    create_table :request_specs do |t|
      t.integer :user_id        #The owner of this spec
      t.integer :application_id #The application that this spec belongs to
      t.string :spec            #The url matching spec
      t.text :note              #A manual note for this spec
      t.integer :response_id    #The response template to respond with
    end
    add_index :request_specs, :application_id, :unique => false
    add_index :request_specs, :user_id, :unique => false
  end
end