require 'spec_helper'
require_relative 'common_helper'
require 'rack/test'

describe AgileProxy::Api::Recordings, api_test: true do
  include Rack::Test::Methods
  include AgileProxy::Test::Api::Common
  let(:applications_assoc_class) do
    Class.new do
    end
  end
  let(:recordings_assoc_class) do
    Class.new do
      def self.destroy_all
      end
    end
  end
  let(:application_instance) { applications_assoc_class.new }

  before :each do
    expect(current_user).to receive(:applications).and_return(applications_assoc_class)
    expect(applications_assoc_class).to receive(:where).with(id: '1').and_return applications_assoc_class
    expect(applications_assoc_class).to receive(:first).and_return application_instance
    expect(application_instance).to receive(:recordings).and_return recordings_assoc_class

  end
  describe 'GET /users/1/applications/1/recordings' do
    let(:recordings_result) do
      [
        {
          application_id: 1,
          request_headers: '{}',
          request_body: '',
          request_url: 'http://www.test.com/1',
          request_method: 'GET',
          response_headers: '{}',
          response_body: '{}',
          response_status: '200'
        }.stringify_keys,
        {
          application_id: 1,
          request_headers: '{}',
          request_body: '',
          request_url: 'http://www.test.com/2',
          request_method: 'GET',
          response_headers: '{}',
          response_body: '{}',
          response_status: '200'
        }.stringify_keys,
        {
          application_id: 1,
          request_headers: '{}',
          request_body: '',
          request_url: 'http://www.test.com/3',
          request_method: 'GET',
          response_headers: '{}',
          response_body: '{}',
          response_status: '200'
        }.stringify_keys
      ]
    end
    before :each do
      expect(recordings_assoc_class).to receive(:page).and_return recordings_assoc_class
      expect(recordings_assoc_class).to receive(:per).and_return recordings_assoc_class
      expect(recordings_assoc_class).to receive(:padding).and_return recordings_assoc_class
      expect(recordings_assoc_class).to receive(:total_count).and_return 3
      expect(recordings_assoc_class).to receive(:num_pages).and_return 1
      expect(recordings_assoc_class).to receive(:current_page).and_return 1
      expect(recordings_assoc_class).to receive(:next_page).and_return 1
      expect(recordings_assoc_class).to receive(:prev_page).and_return 1
      expect(recordings_assoc_class).to receive(:count).and_return 3
      expect(recordings_assoc_class).to receive(:as_json).with({}).and_return recordings_result

    end
    it 'returns a populated array of recordings' do
      get '/v1/users/1/applications/1/recordings'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq('recordings' => recordings_result, 'total' => 3)
    end
  end
  describe 'DELETE /users/1/applications/1/recordings' do
    it 'Should destroy all applications for the user' do
      expect(recordings_assoc_class).to receive(:destroy_all)
      delete '/v1/users/1/applications/1/recordings'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).symbolize_keys).to eql(recordings: [], total: 0)
    end
  end
  describe '/users/1/applications/1/recordings/10' do
    let(:recording_instance) { recordings_assoc_class.new }
    let(:persisted_attributes) { { request_headers: '', response_headers: {} } }
    before :each do
      expect(recordings_assoc_class).to receive(:where).with(id: '10').and_return recordings_assoc_class
      expect(recordings_assoc_class).to receive(:first).and_return recording_instance
      expect(recording_instance).to receive(:as_json).with({}).and_return persisted_attributes
    end
    context 'GET' do
      it 'Should fetch an individual recording' do
        get '/v1/users/1/applications/1/recordings/10'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).symbolize_keys).to eql(persisted_attributes)

      end
    end
    context 'DELETE' do
      it 'Should delete an individual recording' do
        expect(recording_instance).to receive(:destroy)
        delete '/v1/users/1/applications/1/recordings/10'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).symbolize_keys).to eql(persisted_attributes)
      end
    end
  end

end
