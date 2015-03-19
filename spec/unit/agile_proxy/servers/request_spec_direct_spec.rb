require 'spec_helper'
describe AgileProxy::Servers::RequestSpecDirect do
  let(:subject) { AgileProxy::Servers::RequestSpecDirect }
  let(:rack_builder_class)  { Class.new }
  let(:goliath_runner_class) { Class.new }
  let(:rack_static_class) { Class.new }
  let(:rack_cascade_class) { Class.new }
  let(:stub_handler_class) { Class.new }
  before :each do
    stub_const('Goliath::Rack::Builder', rack_builder_class)
    stub_const('Rack::Static', rack_static_class)
    stub_const('Rack::Cascade', rack_cascade_class)
    stub_const('Goliath::Runner', goliath_runner_class)
    stub_const('AgileProxy::StubHandler', stub_handler_class)
  end
  it 'Should start a rack server with a static handler when the start method is called' do
    builder_block = nil
    expect(rack_builder_class).to receive(:app) do |&blk|
      builder_block = blk
      rack_builder_class.new.instance_eval(&blk)
    end
    expect_any_instance_of(rack_builder_class).to receive(:map) do |_instance, path, &blk|
      expect(path).to eql '/'
    end
    expect_any_instance_of(goliath_runner_class).to receive(:run)
    expect_any_instance_of(goliath_runner_class).to receive(:initialize).with([], nil)
    expect_any_instance_of(goliath_runner_class).to receive(:address=).with('localhost')
    expect_any_instance_of(goliath_runner_class).to receive(:port=).with('3030')
    expect_any_instance_of(goliath_runner_class).to receive(:app=)
    subject.start('localhost', '3030', ['/ui', '/images'])

  end
  it 'Should start a rack server with no static handler if the start method is called with 2 params' do
    builder_block = nil
    expect(rack_builder_class).to receive(:app) do |&blk|
      builder_block = blk
      rack_builder_class.new.instance_eval(&blk)
    end
    expect_any_instance_of(rack_builder_class).not_to receive(:use)
    expect_any_instance_of(rack_builder_class).to receive(:map) do |_instance, path, &blk|
      expect(path).to eql '/'
    end
    expect_any_instance_of(goliath_runner_class).to receive(:run)
    expect_any_instance_of(goliath_runner_class).to receive(:initialize).with([], nil)
    expect_any_instance_of(goliath_runner_class).to receive(:address=).with('localhost')
    expect_any_instance_of(goliath_runner_class).to receive(:port=).with('3030')
    expect_any_instance_of(goliath_runner_class).to receive(:app=)
    subject.start('localhost', '3030')

  end
end
