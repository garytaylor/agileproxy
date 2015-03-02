require 'spec_helper'
describe AgileProxy::Servers::Api do
  let(:subject) { AgileProxy::Servers::Api }
  let(:rack_builder_class)  { Class.new }
  let(:goliath_runner_class) { Class.new }
  let(:rack_static_class) { Class.new }
  let(:api_root_class) { Class.new }
  before :each do
    stub_const('Goliath::Rack::Builder', rack_builder_class)
    stub_const('Rack::Static', rack_static_class)
    stub_const('Goliath::Runner', goliath_runner_class)
    stub_const('AgileProxy::Api::Root', api_root_class)
  end
  it 'Should start a goliath server when the start method is called' do
    builder_block = nil
    expect(rack_builder_class).to receive(:app) do |&blk|
      builder_block = blk
      rack_builder_class.new.instance_eval(&blk)
    end
    expect_any_instance_of(rack_builder_class).to receive(:use).with(rack_static_class, root: instance_of(String), urls: ['/ui'], index: 'index.html')
    expect_any_instance_of(rack_builder_class).to receive(:map) do |_instance, path, &blk|
      expect(path).to eql '/api'
      expect_any_instance_of(rack_builder_class).to receive(:run).with(kind_of(api_root_class))
      rack_builder_class.new.instance_eval(&blk)

    end
    expect_any_instance_of(goliath_runner_class).to receive(:run)
    expect_any_instance_of(goliath_runner_class).to receive(:initialize).with([], nil)
    expect_any_instance_of(goliath_runner_class).to receive(:address=).with('localhost')
    expect_any_instance_of(goliath_runner_class).to receive(:port=).with('3020')
    expect_any_instance_of(goliath_runner_class).to receive(:app=)
    subject.start('localhost', '3020')

  end
end
