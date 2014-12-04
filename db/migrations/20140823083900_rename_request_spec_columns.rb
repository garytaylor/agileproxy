class RenameRequestSpecColumns < ActiveRecord::Migration
  def change
    rename_column :request_specs, :spec, :url
    change_table :request_specs do |t|
      t.boolean :regex, :default => false   #Indicates that the url is a regex
    end
  end
end