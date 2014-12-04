require 'spec_helper'

describe AgileProxy::StubHandler do
  let(:route_not_found_response) { [404, { 'X-Cascade' => 'pass' }, ['Not Found']] }
  let(:handler) { AgileProxy::StubHandler.new }
  let(:request) do
    request_for(
        method: 'GET',
        url: 'http://example.test:8080/index?some=param',
        headers: { 'Accept-Encoding' => 'gzip',
                   'Cache-Control' => 'no-cache' }
    )
  end
  let(:application_class) { Class.new }
  let(:request_spec_class) { Class.new }
  let(:application) { application_class.new }

  def request_for(options)
    request = ActionDispatch::Request.new(to_rack_env(options))
    request.params
    request
  end

  before :each do
    stub_const('AgileProxy::Application', application_class)
    allow(application_class).to receive(:where).and_return application_class
    allow(application_class).to receive(:first).and_return application
    allow(application).to receive(:request_specs).and_return request_spec_class
  end
  describe 'With find_stub mocked' do

    describe '#handle_request' do
      it 'returns 404 if the request is not stubbed' do
        stub = double('stub', http_method: 'GET', url: 'http://example.test:8080/index', conditions: {}, call: [404, {}, 'Not found'])
        expect(request_spec_class).to receive(:where).and_return double('association', all: [stub])
        expect(handler.call(to_rack_env(url: 'http://example.test:8080/index'))).to eql [404, {}, 'Not found']
      end

      it 'returns a response hash if the request is stubbed' do
        stub = double('stub', http_method: 'GET', url: 'http://example.test:8080/index', conditions: {}, call: [200, { 'Content-Type' => 'application/json' }, 'Some content'])
        expect(request_spec_class).to receive(:where).and_return double('association', all: [stub])
        expect(handler.call(request.env)).to eql([200, { 'Content-Type' => 'application/json' }, 'Some content'])
      end
      it 'Passes on the correct parameters to the stub call method' do
        stub = double('stub', http_method: 'GET', url: 'http://example.test:8080/index', conditions: {})
        expect(request_spec_class).to receive(:where).and_return double('association', all: [stub])
        body = request.body.read
        request.body.rewind
        expect(stub).to receive(:call).with({ some: 'param' }, { 'Accept-Encoding' => 'gzip', 'Cache-Control' => 'no-cache' }, body).and_return([200, { 'Content-Type' => 'application/json' }, 'Some Content'])
        expect(handler.call(request.env)).to eql([200, { 'Content-Type' => 'application/json' }, 'Some Content'])

      end
      describe 'Routing patterns' do
        describe 'With a simple GET match on the root of a domain' do
          let(:request_stub) { double 'stub', url: 'http://example.com', http_method: 'GET', conditions: {} }
          before :each do
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://example.com%').and_return double('association', all: [request_stub])
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://subdomain.example.com%').and_return double('association', all: [])
            allow(request_stub).to receive(:call).and_return([200, {}, ''])
          end
          it 'Should match with a get on the same domain but not with a post or a different domain' do
            expect(handler.call(request_for(url: 'http://example.com').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/', method: 'POST').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://subdomain.example.com/').env)).to eql route_not_found_response
          end

        end
        describe 'With a simple GET match inside a domain' do
          let(:request_stub) { double 'stub for simple get inside a domain', url: 'http://example.com/index', http_method: 'GET', conditions: {} }
          before :each do
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://example.com%').and_return double('association', all: [request_stub])
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://subdomain.example.com%').and_return double('association', all: [])
            expect(request_stub).to receive(:call).and_return([200, {}, ''])
          end
          it 'Should match with a get on the same domain but not with a post or a different domain' do
            expect(handler.call(request_for(url: 'http://example.com/index').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(method: 'POST', url: 'http://example.com/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://subdomain.example.com/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com/').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com').env)).to eql route_not_found_response
          end

        end
        describe 'With a simple POST match on the root of a domain' do
          let(:request_stub) { double 'stub', url: 'http://example.com', http_method: 'POST', conditions: {} }
          before :each do
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://example.com%').and_return double('association', all: [request_stub])
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://subdomain.example.com%').and_return double('association', all: [])
            allow(request_stub).to receive(:call).and_return([200, {}, ''])
          end
          it 'Should match with a post on the same domain but not with a get or a post on a different domain' do
            expect(handler.call(request_for(method: 'POST', url: 'http://example.com').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(method: 'POST', url: 'http://example.com/').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/').env)).to eql route_not_found_response
            expect(handler.call(request_for(method: 'POST', url: 'http://subdomain.example.com/').env)).to eql route_not_found_response
          end

        end
        describe 'With a more complex route with conditions inside a domain' do
          let(:request_stub) { double 'stub for complex route inside a domain', url: 'http://example.com/users/:user_id/index', http_method: 'GET', conditions: { user_id: '1' }.to_json }
          before :each do
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://example.com%').and_return double('association', all: [request_stub])
            expect(request_stub).to receive(:call).and_return([200, {}, ''])
          end
          it 'Should match with a get on the same domain but not with a post or a different domain' do
            expect(handler.call(request_for(url: 'http://example.com/users/1/index').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/users/2/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(method: 'POST', url: 'http://example.com/users/1/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com/users/1/').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com/users/1').env)).to eql route_not_found_response
          end
        end
        describe 'With a more complex route with conditions including query params inside a domain' do
          let(:request_stub) { double 'stub for complex route inside a domain', url: 'http://example.com/users/:user_id/index', http_method: 'GET', conditions: { user_id: '1', extra_1: 'extra_1', extra_2: 'extra_2' }.to_json }
          before :each do
            allow(request_spec_class).to receive(:where).with('url LIKE ?', 'http://example.com%').and_return double('association', all: [request_stub])
            allow(request_stub).to receive(:call).and_return([200, {}, ''])
          end
          it 'Should match with a get on the same domain but not with a post or a different domain' do
            expect(handler.call(request_for(url: 'http://example.com/users/1/index?extra_1=extra_1&extra_2=extra_2').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/users/1/index?some_other=2&extra_1=extra_1&extra_2=extra_2').env)).to eql([200, {}, ''])
            expect(handler.call(request_for(url: 'http://example.com/users/2/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(method: 'POST', url: 'http://example.com/users/1/index').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com/users/1/').env)).to eql route_not_found_response
            expect(handler.call(request_for(url: 'http://example.com/users/1').env)).to eql route_not_found_response
          end
        end

        # it 'should match regexps' do
        #   expect(AgileProxy::RequestSpec.new(:url => "http:\/\/.+\.com", :method => :post, :regex => true).
        #              matches?('POST', 'http://example.com')).to be
        #   expect(AgileProxy::RequestSpec.new(:url => "http:\/\/.+\.co\.uk", :method => :get, :regex => true).
        #              matches?('GET', 'http://example.com')).to_not be
        # end
        #
        # it 'should match up to but not including query strings' do
        #   stub = AgileProxy::RequestSpec.new(:url => 'http://example.com/foo/bar/')
        #   expect(stub.matches?('GET', 'http://example.com/foo/')).to_not be
        #   expect(stub.matches?('GET', 'http://example.com/foo/bar/')).to be
        #   expect(stub.matches?('GET', 'http://example.com/foo/bar/?baz=bap')).to be
        # end
        # it 'Should match routes using pattern matching' do
        #   stub = AgileProxy::RequestSpec.new(:url => "http://example.com/users/:user_id/application/:application_id")
        #   expect(stub.matches?('GET', 'http://example.com/users/user_id/application/application_id')).to be
        #   expect(stub.matches?('GET', 'http://example.com/users/user_id/somethingelse/application_id')).not_to be
        # end

      end
    end

  end

end
