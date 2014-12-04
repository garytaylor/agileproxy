class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.string :name  #A user friendly name for the response
      t.text :content
      t.string :content_type
      t.integer :status_code, :default => 200
      t.text :headers, :default => "{}"
      t.boolean :is_template
      t.float :delay, :default => 0
      t.timestamps
    end
  end
end