class AddUsernameAndPasswordToApplications < ActiveRecord::Migration
  def change
    change_table(:applications) do |t|
      t.string :username, default: 'anonymous'
      t.string :password, default: 'password'
    end
  end
end