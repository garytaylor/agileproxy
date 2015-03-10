require 'spec_helper'

describe AgileProxy::ProxyHandler do
  subject { AgileProxy::ProxyHandler.new }
  let(:request) do
    ActionDispatch::Request.new to_rack_env(
                                                method: 'post',
                                                url: 'http://example.test:8080/index?some=param',
                                                headers: { 'Accept-Encoding' => 'gzip',
                                                           'Cache-Control' => 'no-cache' },
                                                body: 'Some body'
                                            )
  end

  def request_for_url(url)
    ActionDispatch::Request.new to_rack_env(
                                                method: 'post',
                                                url: url,
                                                headers: { 'Accept-Encoding' => 'gzip',
                                                           'Cache-Control' => 'no-cache' },
                                                body: 'Some body'
                                            )
  end

  describe '#handles_request?' do
    context 'with non-whitelisted requests enabled' do
      before do
        expect(AgileProxy.config).to receive(:non_whitelisted_requests_disabled).and_return(false)
      end
    end
    context 'with non-whitelisted requests disabled' do
      before do
        expect(AgileProxy.config).to receive(:non_whitelisted_requests_disabled).and_return(true)
      end

      it 'does not handle requests that are not white or black listed' do
        expect(subject.send(:handles_request?, request)).to be_falsy
      end

      context 'a whitelisted host' do
        context 'with a blacklisted path' do
          before do
            expect(AgileProxy.config).to receive(:path_blacklist) { ['/index'] }
          end

          it 'does not handle requests for blacklisted paths' do
            req = request_for_url 'http://example.test:8080/index?some=param'
            expect(subject.send(:handles_request?, req)).to be_falsy
          end
        end
        context 'without a port' do
          before do
            expect(AgileProxy.config).to receive(:whitelist) { ['example.test'] }
          end

          it 'handles requests for the host without a port' do
            req = request_for_url 'http://example.test'
            expect(subject.send(:handles_request?, req)).to be_truthy
          end

          it 'handles requests for the host with a port' do
            req = request_for_url 'http://example.test:8080'
            expect(subject.send(:handles_request?, req)).to be_truthy
          end
        end

        context 'with a port' do
          before do
            expect(AgileProxy.config).to receive(:whitelist) { ['example.test:8080'] }
          end

          it 'does not handle requests whitelisted for a specific port' do
            req = request_for_url 'http://example.test'
            expect(subject.send(:handles_request?, req)).to be_falsy
          end

          it 'handles requests for the host with a port' do
            req = request_for_url 'http://example.test:8080'
            expect(subject.send(:handles_request?, req)).to be_truthy
          end
        end
      end
    end
  end

  describe '#call' do
    it 'returns nil if it does not handle the request' do
      expect(subject).to receive(:handles_request?).and_return(false)
      expect(subject.call(request.env)).to eql [404, {}, ['Not proxied']]
    end

    context 'with a handled request' do
      let(:response_header) do
        header = Struct.new(:status, :raw).new
        header.status = 200
        header.raw = {}
        header
      end

      let(:em_response) { double('response') }
      let(:em_request) do
        double('EM::HttpRequest', error: nil, response: em_response, response_header: response_header)
      end

      before do
        allow(subject).to receive(:handles_request?).and_return(true)
        allow(em_response).to receive(:force_encoding).and_return('The response body')
        allow(EventMachine::HttpRequest).to receive(:new).and_return(em_request)
        expect(em_request).to receive(:post).and_return(em_request)
      end

      it 'Should pass through a not allowed response' do
        allow(response_header).to receive(:status).and_return(503)
        expect(subject.call(request.env)).to eql [503, { 'Connection' => 'close', 'Cache-Control' => 'max-age=3600' }, ['The response body']]
      end
      it 'returns any error in the response' do
        allow(em_request).to receive(:error).and_return('ERROR!')
        expect(subject.call(request.env)).to eql([500, {}, ["Request to #{request.url} failed with error: ERROR!"]])
      end

      it 'returns a hashed response if the request succeeds' do
        expect(subject.call(request.env)).to eql([200, { 'Connection' => 'close', 'Cache-Control' => 'max-age=3600' }, ['The response body']])
      end

      it 'returns nil if both the error and response are for some reason nil' do
        allow(em_request).to receive(:response).and_return(nil)
        expect(subject.call(request.env)).to eql [404, {}, ['Not proxied']]
      end

      it 'uses the timeouts defined in configuration' do
        allow(AgileProxy.config).to receive(:proxied_request_inactivity_timeout).and_return(42)
        allow(AgileProxy.config).to receive(:proxied_request_connect_timeout).and_return(24)
        expect(EventMachine::HttpRequest).to receive(:new).with(request.url, inactivity_timeout: 42, connect_timeout: 24)
        subject.call(request.env)
      end
    end
  end
end
