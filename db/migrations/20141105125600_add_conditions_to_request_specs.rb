class AddConditionsToRequestSpecs < ActiveRecord::Migration
  def change
    change_table(:request_specs) do |t|
      t.text :conditions, :default => '{}'    #The conditions object used for matching
    end
  end
end