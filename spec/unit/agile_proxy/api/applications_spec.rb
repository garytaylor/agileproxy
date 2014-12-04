require 'spec_helper'
require_relative './common_helper'
require 'rack/test'

describe AgileProxy::Api::Applications, api_test: true do
  include Rack::Test::Methods
  include AgileProxy::Test::Api::Common
  let(:applications_assoc_class) { Class.new }

  describe 'GET /users/1/applications' do
    let(:applications_result) do
      [
        { username: 'user1', password: 'password1', name: 'application1', record_requests: true, user_id: current_user.id }.stringify_keys,
        { username: 'user1', password: 'password2', name: 'application2', record_requests: true, user_id: current_user.id }.stringify_keys,
        { username: 'user1', password: 'password3', name: 'application3', record_requests: true, user_id: current_user.id }.stringify_keys
      ]
    end
    before :each do
      expect(current_user).to receive(:applications).and_return(applications_assoc_class)
      expect(applications_assoc_class).to receive(:page).and_return applications_assoc_class
      expect(applications_assoc_class).to receive(:per).and_return applications_assoc_class
      expect(applications_assoc_class).to receive(:padding).and_return applications_assoc_class
      expect(applications_assoc_class).to receive(:total_count).and_return 3
      expect(applications_assoc_class).to receive(:num_pages).and_return 1
      expect(applications_assoc_class).to receive(:current_page).and_return 1
      expect(applications_assoc_class).to receive(:next_page).and_return 1
      expect(applications_assoc_class).to receive(:prev_page).and_return 1
      expect(applications_assoc_class).to receive(:count).and_return 3
      expect(applications_assoc_class).to receive(:as_json).and_return(applications_result)
    end
    it 'returns a populated array of applications' do
      get '/v1/users/1/applications'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq('applications' => applications_result, 'total' => 3)
    end
  end
  describe 'POST /users/1/applications' do
    let(:create_attributes) { { username: 'user1', password: 'password', name: 'application1', record_requests: true } }
    let(:to_be_created_attributes) { create_attributes.merge(user_id: current_user.id, record_requests: 'true').stringify_keys }
    let(:created_attributes) { to_be_created_attributes }
    let(:mock_application) { double('AgileProxy::Application', create_attributes) }
    before :each do
      expect(current_user).to receive(:applications).and_return applications_assoc_class
      expect(applications_assoc_class).to receive(:create!).with(to_be_created_attributes).and_return(mock_application)
      expect(mock_application).to receive(:as_json).and_return(to_be_created_attributes)
    end
    it 'Creates a new application and returns it' do
      post '/v1/users/1/applications', create_attributes, 'Content-Type' => 'application/json'
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to eql(created_attributes)
    end
  end
  describe 'DELETE /users/1/applications' do
    before :each do
      expect(current_user).to receive(:applications).and_return(applications_assoc_class)
      expect(applications_assoc_class).to receive(:destroy_all)
    end
    it 'Should destroy all applications for the user' do
      delete '/v1/users/1/applications'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).symbolize_keys).to eql(applications: [], total: 0)
    end
  end
  describe '/users/1/applications/10' do
    let(:persisted_attributes) { { username: 'user1', password: 'password', name: 'application10', record_requests: true, id: 10 } }
    let(:mock_application) { double('AgileProxy::Application', persisted_attributes) }
    before :each do
      expect(current_user).to receive(:applications).and_return(applications_assoc_class)
      expect(applications_assoc_class).to receive(:where).with(id: '10').and_return applications_assoc_class
      expect(applications_assoc_class).to receive(:first).and_return mock_application
      expect(mock_application).to receive(:as_json).with({}).and_return persisted_attributes
    end
    context 'GET' do
      it 'Should retrieve the application from persistence store' do
        get '/v1/users/1/applications/10'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).symbolize_keys).to eql(persisted_attributes)
      end
    end
    context 'DELETE' do
      it 'Should call destroy on the application found' do
        expect(mock_application).to receive(:destroy)
        delete '/v1/users/1/applications/10'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).symbolize_keys).to eql(persisted_attributes)
      end
    end
    context 'PUT' do
      let(:to_be_updated_attributes) { { username: 'user1', password: 'password', name: 'application10 new name', record_requests: 'true' }.stringify_keys }
      let(:updated_attributes) { to_be_updated_attributes.merge(record_requests: true).stringify_keys }
      it 'Should call update_attributes on the application found' do
        expect(mock_application).to receive(:update_attributes).with(to_be_updated_attributes)
        persisted_attributes.merge! updated_attributes
        persisted_attributes.delete(:id) # We dont allow modification of the id
        put '/v1/users/1/applications/10', to_be_updated_attributes
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eql(updated_attributes)

      end
    end
  end
end
