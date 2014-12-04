class AddUrlTypeToRequestSpecs < ActiveRecord::Migration
  def change
    change_table(:request_specs) do |t|
      t.string :url_type, :default => 'url'    #The http method
    end
    remove_column :request_specs, :regex, :boolean
  end
end