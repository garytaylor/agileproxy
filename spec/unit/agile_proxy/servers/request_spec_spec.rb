require 'spec_helper'
describe AgileProxy::Servers::RequestSpec do
  let(:subject) { AgileProxy::Servers::RequestSpec }
  let(:event_machine_class) { Class.new }
  let(:socket_class) { Class.new }
  let(:proxy_connection_class) { Class.new }
  let(:request_handler_class) { Class.new }
  before :each do
    stub_const('EM', event_machine_class)
    stub_const('Socket', socket_class)
    stub_const('AgileProxy::ProxyConnection', proxy_connection_class)
    stub_const('AgileProxy::RequestHandler', request_handler_class)
  end
  context 'With started server' do
    before :each do
      expect(event_machine_class).to receive(:start_server).with('127.0.0.1', AgileProxy.config.proxy_port, proxy_connection_class) do |_host, _port, _connection_class, &blk|
        connection_instance = proxy_connection_class.new
        expect(connection_instance).to receive(:handler=).with(kind_of(request_handler_class))
        blk.call(connection_instance)
      end.and_return 'signature'
    end
    it 'Should start the server and return the instance' do
      expect(subject.start).to be_a_kind_of(subject)
    end
    it 'Should return the port it is running on' do
      expect(event_machine_class).to receive(:get_sockname).with('signature').and_return 'sockname'
      expect(socket_class).to receive(:unpack_sockaddr_in).with('sockname').and_return ['3100']
      expect(subject.start.port).to eql '3100'

    end
  end
end
