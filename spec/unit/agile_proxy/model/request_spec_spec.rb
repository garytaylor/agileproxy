require 'agile_proxy/model/request_spec'
describe AgileProxy::RequestSpec do
  let(:response_class) do
    Class.new do
      def initialize(config = {})
        @config = config
      end
      attr_accessor :config

    end
  end
  let(:mock_response) { response_class.new }
  before :each do
    stub_const('AgileProxy::Response', response_class)
  end
  it 'Should allow a nested response' do
    subject.should accept_nested_attributes_for(:response)
  end
  it 'Should belong to a user' do
    expect(subject).to belong_to(:user)
  end
  it 'Should belong to an application' do
    expect(subject).to belong_to(:application)
  end
  it 'Should belong to a response' do
    expect(subject).to belong_to(:response)
  end

  describe 'Interface for the stub handler' do
    context '#call (without #and_return)' do
      let(:subject) { AgileProxy::RequestSpec.new(url: 'url') }
      it 'returns a 204 empty response' do
        expect(subject).to receive(:response).and_return nil
        expect(subject.call({}, {}, nil)).to eql [204, { 'Content-Type' => 'text/plain' }, '']
      end
    end
    context '#call With conditions' do
      let(:subject) { AgileProxy::RequestSpec.new(url: 'url', conditions: '{"a": 1, "b": 2}') }
      it 'returns a the correct json' do
        expect(subject.conditions_json).to eql('a' => 1, 'b' => 2)
      end

    end
  end
end
