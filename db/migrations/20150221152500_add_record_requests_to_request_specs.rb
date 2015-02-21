class AddRecordRequestsToRequestSpecs < ActiveRecord::Migration
  def change
    change_table(:request_specs) do |t|
      t.boolean :record_requests, default: false
    end
  end
end