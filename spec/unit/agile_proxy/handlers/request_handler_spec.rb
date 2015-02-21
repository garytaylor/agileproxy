require 'spec_helper'

describe AgileProxy::RequestHandler do
  subject { AgileProxy::RequestHandler.new }

  it 'implements Handler' do
    expect(subject).to be_a AgileProxy::Handler
  end

  context 'with stubbed handlers' do
    let(:env) { to_rack_env(url: 'http://dummy.host.com/index.html').merge('agile_proxy.request_spec' => mock_request_spec) }
    let(:stub_handler) { Class.new }
    let(:proxy_handler) { Class.new }
    let(:application_class) { Class.new }
    let(:recordings_class) { Class.new }
    let(:application) { double('Application', record_requests: false, recordings: recordings_class) }
    let(:mock_request_spec) {double('RequestSpec', id: 8, record_requests: false)}

    before do
      stub_const 'AgileProxy::StubHandler', stub_handler
      stub_const 'AgileProxy::ProxyHandler', proxy_handler
      stub_const 'AgileProxy::Application', application_class
      allow(application_class).to receive(:where).and_return [application]
    end

    describe '#call' do
      it 'returns error 500 if no handlers handle the request' do
        expect_any_instance_of(stub_handler).to receive(:call).and_return [404, {}, 'It didnt work']
        expect_any_instance_of(proxy_handler).to receive(:call).and_return [404, {}, 'It didnt work']
        expect(subject.call(env)).to start_with [500, {}]
      end

      it 'returns 200 immediately if the stub handler handles the request' do
        expect_any_instance_of(stub_handler).to receive(:call).with(env).and_return [200, {}, 'Some data']
        expect_any_instance_of(proxy_handler).to_not receive(:call)
        expect(subject.call(env)).to eql [200, {}, 'Some data']
      end

      it 'returns true if the proxy handler handles the request' do
        expect_any_instance_of(stub_handler).to receive(:call).with(env).and_return [404, {}, 'Irrelevant']
        expect_any_instance_of(proxy_handler).to receive(:call).with(env).and_return [200, {}, 'Some data']
        expect(subject.call(env)).to eql [200, {}, 'Some data']
      end

      it 'Calls application.recordings.create with a reference to the stub if record_requests is true on the application' do
        allow(application).to receive(:record_requests).and_return true
        expect(application.recordings).to receive(:create).with(a_hash_including request_spec_id: 8)
        expect_any_instance_of(stub_handler).to receive(:call).with(env).and_return [200, {}, 'Some data']
        expect_any_instance_of(proxy_handler).to_not receive(:call)
        expect(subject.call(env)).to eql [200, {}, 'Some data']
      end
      it 'Calls application.recordings.create with a reference to the stub if record_requests is true on the request spec' do
        allow(mock_request_spec).to receive(:record_requests).and_return true
        expect(application.recordings).to receive(:create).with(a_hash_including request_spec_id: 8)
        expect_any_instance_of(stub_handler).to receive(:call).with(env).and_return [200, {}, 'Some data']
        expect_any_instance_of(proxy_handler).to_not receive(:call)
        expect(subject.call(env)).to eql [200, {}, 'Some data']
      end

    end

  end
end
