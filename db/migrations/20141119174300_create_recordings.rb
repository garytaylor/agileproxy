class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.integer :application_id
      t.text :request_headers
      t.text :request_body
      t.string :request_url
      t.string :request_method
      t.text :response_headers
      t.text :response_body
      t.text :response_status
      t.integer :request_spec_id
      t.timestamps
    end
    add_index :recordings, :application_id, :unique => false
    add_index :recordings, :request_spec_id, :unique => false
  end
end