class AddMethodToRequestSpecs < ActiveRecord::Migration
  def change
    change_table(:request_specs) do |t|
      t.string :http_method, :default => 'GET'    #The http method
    end
  end
end