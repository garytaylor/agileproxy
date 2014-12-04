class AddRecordToApplications < ActiveRecord::Migration
  def change
    change_table(:applications) do |t|
      t.boolean :record_requests, default: false
    end
  end
end