require 'spec_helper'

describe AgileProxy::Server do
  let(:subject) { AgileProxy::Server.new }
  let(:active_record_base_class) do
    Class.new do
      def self.establish_connection(_options)
      end
      class << self
        attr_accessor :configurations
      end
    end
  end
  let(:request_spec_server_class) { Class.new }
  let(:api_server_class) { Class.new }
  let(:em_class) { Class.new }
  let(:socket_class) { Class.new }
  before :each do
    stub_const('ActiveRecord::Base', active_record_base_class)
    stub_const('::EM', em_class)
    stub_const('AgileProxy::Servers::Api', api_server_class)
    stub_const('AgileProxy::Servers::RequestSpec', request_spec_server_class)
  end
  context 'Initialization' do
    context 'In test environment' do
      before :each do
        expect(AgileProxy.config).to receive(:environment).and_return 'test'
        expect(active_record_base_class).to receive(:establish_connection).with('adapter' => 'sqlite3', 'database' => 'db/test.db')
      end
      it 'Should establish the correct active record connection according to the environment' do
        subject

      end
    end
    context 'In development environment' do
      before :each do
        expect(AgileProxy.config).to receive(:environment).and_return 'development'
        expect(active_record_base_class).to receive(:establish_connection).with('adapter' => 'sqlite3', 'database' => 'db/development.db')
      end
      it 'Should establish the correct active record connection according to the environment' do
        subject

      end
    end
  end
  context 'Starting the servers' do
    it 'Should alias start to main_loop' do
      expect(subject).to receive(:main_loop)
      subject.start
    end
  end
  context 'Within Main Loop' do

    # Note that we are not really testing the main loop here - it is better tested using integration tests which exercise it properly
    inner_loop = nil
    error_handler = nil
    before :each do
      expect(em_class).to receive(:error_handler) do |&blk|
        error_handler = blk
      end
      expect(api_server_class).to receive(:start).with('localhost', 3020)
      expect_any_instance_of(request_spec_server_class).to receive(:port).at_least(:once).and_return '3100'
      expect(em_class).to receive(:run) do |&blk|
        inner_loop = blk
      end
      expect(request_spec_server_class).to receive(:start).and_return request_spec_server_class.new
      subject.start
      inner_loop.call
    end
    context 'Server accessors' do
      it 'Should return something from url' do
        expect(subject.url).to eql 'http://localhost:3100'
      end
      it 'Should return something from webserver_host' do
        expect(subject.webserver_host).to eql 'localhost'
      end
    end
    context 'Error handler' do
      let(:exception) { StandardError.new('This is a test error') }
      it 'Should output the errors to stdout' do
        expect(subject).to receive(:puts).at_least(:once)
        expect(exception).to receive(:backtrace).and_return %w(line1 line2)
        error_handler.call(exception)
      end
    end

  end
end
