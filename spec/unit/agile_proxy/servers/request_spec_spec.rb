require 'spec_helper'
describe AgileProxy::Servers::RequestSpec do
  let(:subject) { AgileProxy::Servers::RequestSpec }
  let(:rack_builder_class)  { Class.new }
  let(:goliath_runner_class) { Class.new }
  let(:rack_static_class) { Class.new }
  let(:request_handler_class) { Class.new }
  let(:config_class) {Class.new}
  before :each do
    stub_const('Goliath::Rack::Builder', rack_builder_class)
    stub_const('Rack::Static', rack_static_class)
    stub_const('Goliath::Proxy::Runner', goliath_runner_class)
    stub_const('AgileProxy::RequestHandler', request_handler_class)
    stub_const('AgileProxy::Config', config_class)
  end
  context 'With started server' do
    before :each do
      expect_any_instance_of(goliath_runner_class).to receive(:run)
      expect_any_instance_of(goliath_runner_class).to receive(:initialize).with([], nil)
      expect_any_instance_of(goliath_runner_class).to receive(:address=).with('127.0.0.1')
      expect_any_instance_of(goliath_runner_class).to receive(:port=).with('3100')
      expect_any_instance_of(goliath_runner_class).to receive(:app=).with(instance_of(request_handler_class))
      expect(AgileProxy).to receive(:config).at_least(:once).and_return config_class.new
      expect_any_instance_of(config_class).to receive(:proxy_port).at_least(:once).and_return '3100'
      allow_any_instance_of(config_class).to receive(:reset)
    end
    it 'Should start the server and return the instance' do
      expect(subject.start).to be_a_kind_of(subject)
    end
    it 'Should return the port it is running on' do
      expect(subject.start.port).to eql '3100'

    end
  end
end
