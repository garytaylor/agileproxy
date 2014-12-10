require 'spec_helper'
require_relative 'common_helper'
require 'rack/test'

describe AgileProxy::Api::RequestSpecs, api_test: true do
  include Rack::Test::Methods
  include AgileProxy::Test::Api::Common
  let(:applications_assoc_class) do
    Class.new do
    end
  end
  let(:request_spec_assoc_class) do
    Class.new do
      def self.destroy_all
      end
    end
  end
  let(:application_instance) { applications_assoc_class.new }
  before :each do
    expect(current_user).to receive(:applications).at_least(:once).and_return(applications_assoc_class)
    expect(applications_assoc_class).to receive(:where).with(id: '1').at_least(:once).and_return applications_assoc_class
    expect(applications_assoc_class).to receive(:first).at_least(:once).and_return application_instance
    expect(application_instance).to receive(:request_specs).and_return request_spec_assoc_class
  end
  let(:default_json_spec) { { include: { response: { except: [:created_at, :updated_at] } } } }

  # def mock_collection_data
  #   @__all_request_specs ||= [double('HttpFlexiblePrAgileProxy', :id => 1),double('AgileProxy::ReAgileProxy=> 2),double('AgileProxy::RequestSpAgileProxyeach do |d|
  #     allow(d).to receive(:as_json).with(default_json_spec).and_return({:spec => "Spec #{d.id}"}.as_json)
  #   end
  # end
  # def mock_collection_association
  #   return @__mock_collection_association if @__mock_collection_association.present?
  #   @__mock_collection_association = double('Mock Association')
  #   @__mock_collection_association.tap do |o|
  #     allow(o).to receive(:total_count).and_return 3
  #     allow(o).to receive(:num_pages).and_return 1
  #     allow(o).to receive(:current_page).and_return 1
  #     allow(o).to receive(:next_page).and_return nil
  #     allow(o).to receive(:prev_page).and_return nil
  #     allow(o).to receive(:page).and_return o
  #     allow(o).to receive(:per).and_return o
  #     allow(o).to receive(:padding).and_return o
  #   end
  #   allow(@__mock_collection_association).to receive(:as_json).with(default_json_spec).and_return(mock_collection_data.as_json(default_json_spec))
  #   allow(@__mock_collection_association).to receive(:count).and_return 3
  #   allow(@__mock_collection_association).to receive(:where) do |options|
  #     if options.key?(:id)
  #       mock_collection_data.select{|r| r.id.to_s == options[:id]}
  #     else
  #       throw "mock_collection_association called with an unknown where clause of #{where.to_json}"
  #     end
  #   end
  #   @__mock_collection_association
  # end
  # def created_member(attrs)
  #   double("AgileProxy::RequestSpec", attrs.merge({:as_json => {"spec" => attrs[:spec]}}))
  # end
  describe 'GET /users/1/applications/1/request_specs' do
    let(:request_specs_result) do
      [{ 'spec' => 'Spec 1' }, { 'spec' => 'Spec 2' }, { 'spec' => 'Spec 3' }]
    end
    before :each do
      expect(request_spec_assoc_class).to receive(:page).and_return request_spec_assoc_class
      expect(request_spec_assoc_class).to receive(:per).and_return request_spec_assoc_class
      expect(request_spec_assoc_class).to receive(:padding).and_return request_spec_assoc_class
      expect(request_spec_assoc_class).to receive(:total_count).and_return 3
      expect(request_spec_assoc_class).to receive(:num_pages).and_return 1
      expect(request_spec_assoc_class).to receive(:current_page).and_return 1
      expect(request_spec_assoc_class).to receive(:next_page).and_return 1
      expect(request_spec_assoc_class).to receive(:prev_page).and_return 1
      expect(request_spec_assoc_class).to receive(:count).and_return 3
      expect(request_spec_assoc_class).to receive(:as_json).with(default_json_spec).and_return request_specs_result
    end
    it 'returns a populated array of request specs' do
      get '/v1/users/1/applications/1/request_specs'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq('request_specs' => [{ 'spec' => 'Spec 1' }, { 'spec' => 'Spec 2' }, { 'spec' => 'Spec 3' }], 'total' => 3)
    end
    it 'Should not list items from a different application'
    it 'Should not list items that belong to a different user'
  end
  describe '/users/1/applications/1/request_specs/2' do
    let(:request_spec_instance) { request_spec_assoc_class.new }
    let(:persisted_attributes) { { user_id: 1, application_id: 1, url: 'http://www.test.com', http_method: 'GET' } }
    before :each do
      expect(request_spec_assoc_class).to receive(:where).with(id: '2').and_return request_spec_assoc_class
      expect(request_spec_assoc_class).to receive(:first).and_return request_spec_instance
      expect(request_spec_instance).to receive(:as_json).with(default_json_spec).and_return persisted_attributes
    end
    describe 'GET' do
      it 'returns a single item in json format' do
        get '/v1/users/1/applications/1/request_specs/2'
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).symbolize_keys).to eq(persisted_attributes)
      end
      it 'Should not find a request spec which does not belong to the application specified'
      it 'Should not find a request spec which does not belong to the user specified'
    end
    describe 'PUT' do
      it 'Should update an existing item with the attributes given' do
        expect(current_user).to receive(:id).and_return(1)
        expect(application_instance).to receive(:id).and_return(1)
        expect(request_spec_instance).to receive(:update_attributes).with(spec: 'Renamed Spec 2', user_id: 1, application_id: 1).and_return true
        put '/v1/users/1/applications/1/request_specs/2', { spec: 'Renamed Spec 2' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body).symbolize_keys).to eq(persisted_attributes)  # Note that the mocked update_attributes doesnt actually update so the original json is expected
      end
    end
    describe 'DELETE' do
      it 'Should delete the existing item and return it in json form' do
        expect(request_spec_instance).to receive(:destroy)
        delete '/v1/users/1/applications/1/request_specs/2'
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body).symbolize_keys).to eq(persisted_attributes)
      end
      it 'Should not allow deleting of other peoples request specs'
    end
  end
  describe 'POST /users/1/applications/1/request_specs' do
    let(:request_spec_instance) { request_spec_assoc_class.new }
    let(:persisted_attributes) { { user_id: 1, application_id: 1, url: 'http://www.test.com', http_method: 'GET' } }
    before :each do
      expect(request_spec_instance).to receive(:as_json).with(default_json_spec).and_return(persisted_attributes)
      expect(current_user).to receive(:id).and_return(1)
      expect(application_instance).to receive(:id).and_return(1)
    end
    it 'Should create a new item with the correct attributes set' do
      expect(request_spec_assoc_class).to receive(:create).with(spec: 'Spec 4', user_id: 1, application_id: 1).and_return request_spec_instance
      post '/v1/users/1/applications/1/request_specs', { spec: 'Spec 4' }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect([200, 201]).to include(last_response.status)
      expect(JSON.parse(last_response.body).symbolize_keys).to eq(persisted_attributes)
    end
    it 'Should allow creating of a response object also' do
      response_attributes = { name: 'Test Response', content: '<h1>Hello World</h1>', content_type: 'text/html', status_code: 200, headers: '{}', is_template: false }
      expect(request_spec_assoc_class).to receive(:create).with(spec: 'Spec 4', user_id: 1, application_id: 1, response_attributes: Hashie::Mash.new(response_attributes)).and_return request_spec_instance
      post '/v1/users/1/applications/1/request_specs', { spec: 'Spec 4', response: response_attributes }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect([200, 201]).to include(last_response.status)
      expect(JSON.parse(last_response.body).symbolize_keys).to eq(persisted_attributes)
    end
    it 'Should inform the router of the new entry'
    it 'Should not allow the user to specify the user_id to prevent creating for a different user'
    it 'Should not allow setting of an application_id which doesnt belong to the current user'
  end
  describe 'DELETE /users/1/applications/1/request_specs' do
    before :each do
      expect(request_spec_assoc_class).to receive(:destroy_all)
    end
    it 'Should delete all request specs for the users application' do
      delete '/v1/users/1/applications/1/request_specs'
      expect(JSON.parse(last_response.body).symbolize_keys).to eq(request_specs: [], total: 0)

    end
  end
  it 'Should not find other peoples request specs to update'
  it 'Should not allow updates of the user_id to prevent changing ownership'
  it 'Should not allow updates of the application_id to prevent changing ownership via the application'
  it 'Should inform the router of the update if the spec or response has changed'
end
