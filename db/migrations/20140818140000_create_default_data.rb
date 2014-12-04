require_relative '../../lib/agile_proxy/model/user'
class CreateDefaultData < ActiveRecord::Migration
  def up
    AgileProxy::User.create(:name => 'Default User', :applications => [AgileProxy::Application.new(:name => "Default Application")])
  end
  def down
    record = AgileProxy::User.where(:name => 'Default User').first
    record.destroy if record.present?
  end
end