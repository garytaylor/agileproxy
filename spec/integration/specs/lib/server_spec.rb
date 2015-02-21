require 'integration_spec_helper'

# require 'spec_helper'
require 'agile_proxy'
require 'resolv'
require 'rest_client'

shared_examples_for 'a proxy server' do |options = {}|
  if options.key?(:recording) && options[:recording]
    after :each do
      expect(JSON.parse(recordings_resource.get)['total']).to eql(1)
    end
  end
  it 'should proxy GET requests' do
    expect(http.get('/echo').body).to eql 'GET /echo'
  end

  it 'should proxy POST requests' do
    expect(http.post('/echo', foo: 'bar').body).to eql "POST /echo\nfoo=bar"
  end

  it 'should proxy PUT requests' do
    expect(http.post('/echo', foo: 'bar').body).to eql "POST /echo\nfoo=bar"
  end

  it 'should proxy HEAD requests' do
    expect(http.head('/echo').headers['HTTP-X-EchoServer']).to eql 'HEAD /echo'
  end

  it 'should proxy DELETE requests' do
    expect(http.delete('/echo').body).to eql 'DELETE /echo'
  end
end

shared_examples_for 'a request stub' do |options = {}|
  recording = false
  if options.key?(:recording) && options[:recording]
    recording = true
    after :each do
      data = recordings_resource.get
      count = JSON.parse(data)['total']
      expect(count).to eql(1)
    end
  end
  def find_stub(client, name)
    @stubs_with_recordings.select { |stub| stub.url == client.url_prefix.to_s && stub.name == name}.first
  end
  def rest_client_for_stub(stub)
    RestClient::Resource.new("http://localhost:#{api_port}/api/v1/users/1/applications/#{@recording_application_id}/request_specs/#{stub.body[:id]}/recordings", content_type: :json )
  end
  def recordings_for(name)
    stub = find_stub(http, name)
    JSON.parse(rest_client_for_stub(stub).get).with_indifferent_access
  end
  def recordings_matcher_for(name, path)
    stub = find_stub(http, name)
    {recordings: a_collection_containing_exactly(a_hash_including request_body: '', request_url: "#{http.url_prefix}#{path.gsub(/^\//, '')}", request_method: 'GET', request_spec_id: stub.body[:id])}
  end
  it 'should stub GET requests' do
    expect(http.get('/index.html').body).to eql '<html><body>Mocked Content</body></html>'
    expect(recordings_for 'index').to include(recordings_matcher_for('index', '/index.html')) if recording
  end

  it 'should stub GET response statuses' do
    expect(http.get('/index.html').status).to eql 200
  end

  #TODO When time allows, work out how to easily test this as the stubs are not recorded for anything but recorded tests
  #the lookup table would need to contain all stubs and we would need a way of indexing them to allow the test to find
  # the correct one.
  xit 'Should record a stub if specified in the stub irrespective of whether app is recording or not' do
    expect(http.get('/indexRecording.html').status).to eql 200
    expect(recordings_for('index_recording')).to include(recordings_matcher_for('index_recording', '/indexRecording.html'))
  end

  it 'Should stub a different get request with json response' do
    resp = http.get('/api/forums')
    expect(ActiveSupport::JSON.decode(resp.body).symbolize_keys).to eql forums: [], total: 0
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'application/json'
    expect(recordings_for 'api_forums').to include(recordings_matcher_for('api_forums', '/api/forums')) if recording
  end

  it 'Should get the mocked content with parameter substitution for the /api/forums/:forum_id/posts url' do
    resp = http.get '/api/forums/my_forum/posts'
    expect(ActiveSupport::JSON.decode(resp.body)).to eql 'posts' => [{ 'forum_id' => 'my_forum', 'subject' => 'My first post' }, { 'forum_id' => 'my_forum', 'subject' => 'My second post' }, { 'forum_id' => 'my_forum', 'subject' => 'My third post' }], 'total' => 3
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'application/json'
  end

  it 'Should get the mocked content for api/forums/:forum_id/:post_id with parameter substitution including query parameters' do
    resp = http.get '/api/forums/my_forum/my_post?sort=id'
    expect(resp.body).to eql '<html><body><h1>Sorted By: id</h1><h2>my_forum</h2><h3>my_post</h3></body></html>'
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'text/html'
  end
  it 'Should get the mocked content for api/forums/:forum_id/:post_id.html with parameter substitution including query parameters' do
    resp = http.get '/api/forums/my_forum/my_post.html?sort=id'
    expect(resp.body).to eql '<html><body><h1>Sorted By: id</h1><h2>my_forum</h2><h3>my_post</h3></body></html>'
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'text/html'
  end
  it 'Should respond with an error for api/forums/:forum_id/:post_id.html with parameter substitution with a missing query parameter' do
    resp = http.get '/api/forums/my_forum/my_post.html'
    expect(resp.body).to eql '<html><body><h1>Sorted By: </h1><h2>my_forum</h2><h3>my_post</h3></body></html>'
    expect(resp.status).to eql 200
  end
  it 'Should match the route by posted json data and the posted data can be output via the template' do
    resp = http.post '/api/forums/my_forum', '{"posted_var": "special_value"}', 'Content-Type' => 'application/json'
    expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'text/html'
  end
  it 'Should match the route by posted plain text data and the posted data can be output via the template' do
    resp = http.post '/api/forums/my_forum', "posted_var=special_value\n", 'Content-Type' => 'text/plain'
    expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'text/html'
  end
  it 'Should match the route by posted plain text data and the posted data can be output via the template' do
    resp = http.post '/api/forums/my_forum', "dummy=\nposted_var=special_value\n", 'Content-Type' => 'text/plain'
    expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
    expect(resp.status).to eql 200
    expect(resp.headers['Content-Type']).to eql 'text/html'
  end
  # it 'Should match the route by posted xml data and the posted data can be output via the template' do
  #   resp = http.post "/api/forums/my_forum", '<posted_var>special_value</posted_var>', {'Content-Type' => 'application/xml'}
  #   expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
  #   expect(resp.status).to eql 200
  # end
  it 'Should match the route by posted url encoded data and the posted data can be output via the template' do
    resp = http.post '/api/forums/my_forum', 'posted_var=special_value', 'Content-Type' => 'application/x-www-form-urlencoded'
    expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
    expect(resp.status).to eql 200
  end
  it 'Should match the route by posted multipart encoded data and the posted data can be output via the template' do
    resp = http.post '/api/forums/my_forum', 'posted_var=special_value', 'Content-Type' => 'multipart/form-data'
    expect(resp.body).to eql '<html><body><h1></h1><h2>special_value</h2><h3>my_forum</h3><p>This should get data from the POSTed data</p></body></html>'
    expect(resp.status).to eql 200
  end

  it 'should stub POST requests' do
    resp = http.post('/api/forums', foo: :bar)
    expect(resp.body).to eql '{"created": true}'
    expect(resp.headers['Content-Type']).to eql 'application/json'

  end

  it 'should stub PUT requests' do
    resp = http.put('/api/forums/forum_1/my_post', foo: :bar)
    expect(resp.body).to eql '{"updated": true}'
    expect(resp.headers['Content-Type']).to eql 'application/json'
  end

  it 'should stub DELETE requests' do
    resp = http.delete('/api/forums/forum_1/my_post')
    expect(resp.body).to eql '{"deleted": true}'
    expect(resp.headers['Content-Type']).to eql 'application/json'
  end
end

shared_examples_for 'a cache' do

  context 'whitelisted GET requests' do
    it 'should not be cached' do
      assert_noncached_url
    end

    context 'with ports' do
      before do
        rack_app_url = URI(http.url_prefix)
        AgileProxy.config.whitelist = ["#{rack_app_url.host}:#{rack_app_url.port}"]
      end

      it 'should not be cached ' do
        assert_noncached_url
      end
    end
  end

  context 'non-whitelisted GET requests' do
    before do
      AgileProxy.config.whitelist = []
    end

    it 'should be cached' do
      assert_cached_url
    end

    context 'with ports' do
      before do
        rack_app_url = URI(http.url_prefix)
        AgileProxy.config.whitelist = ["#{rack_app_url.host}:#{rack_app_url.port + 1}"]
      end

      it 'should be cached' do
        assert_cached_url
      end
    end
  end

  context 'ignore_params GET requests' do
    before do
      AgileProxy.config.ignore_params = ['/analytics']
    end

    it 'should be cached' do
      r = http.get('/analytics?some_param=5')
      expect(r.body).to eql 'GET /analytics'
      expect do
        expect do
          r = http.get('/analytics?some_param=20')
        end.to change { r.headers['HTTP-X-EchoCount'].to_i }.by(1)
      end.to_not change { r.body }
    end
  end

  context 'path_blacklist GET requests' do
    before do
      AgileProxy.config.path_blacklist = ['/api']
    end

    it 'should be cached' do
      assert_cached_url('/api')
    end
  end

  context 'cache persistence' do
    let(:cached_key) { proxy.cache.key('get', "#{url}/foo", '') }
    let(:cached_file) do
      f = cached_key + '.yml'
      File.join(AgileProxy.config.cache_path, f)
    end

    before { AgileProxy.config.whitelist = [] }

    after do
      File.delete(cached_file) if File.exist?(cached_file)
    end

    context 'enabled' do
      before { AgileProxy.config.persist_cache = true }

      it 'should persist' do
        http.get('/foo')
        expect(File.exist?(cached_file)).to be_true
      end

      it 'should be read initially from persistent cache' do
        File.open(cached_file, 'w') do |f|
          cached = {
            headers: {},
            content: 'GET /foo cached'
          }
          f.write(cached.to_yaml(Encoding: :Utf8))
        end

        r = http.get('/foo')
        expect(r.body).to eql 'GET /foo cached'
      end

      context 'cache_request_headers requests' do
        it 'should not be cached by default' do
          http.get('/foo')
          saved_cache = AgileProxy.proxy.cache.fetch_from_persistence(cached_key)
          expect(saved_cache.keys).not_to include :request_headers
        end

        context 'when enabled' do
          before do
            AgileProxy.config.cache_request_headers = true
          end

          it 'should be cached' do
            http.get('/foo')
            saved_cache = AgileProxy.proxy.cache.fetch_from_persistence(cached_key)
            expect(saved_cache.keys).to include :request_headers
          end
        end
      end

      context 'ignore_cache_port requests' do
        it 'should be cached without port' do
          r   = http.get('/foo')
          url = URI(r.env[:url])
          saved_cache = AgileProxy.proxy.cache.fetch_from_persistence(cached_key)

          expect(saved_cache[:url]).to_not eql(url.to_s)
          expect(saved_cache[:url]).to eql(url.to_s.gsub(":#{url.port}", ''))
        end
      end

      context 'non_whitelisted_requests_disabled requests' do
        before { AgileProxy.config.non_whitelisted_requests_disabled = true }

        it 'should raise error when disabled' do
          # TODO: Suppress stderr output: https://gist.github.com/adamstegman/926858
          expect { http.get('/foo') }.to raise_error(Faraday::Error::ConnectionFailed, 'end of file reached')
        end
      end

      context 'non_successful_cache_disabled requests' do
        before do
          rack_app_url = URI(http_error.url_prefix)
          AgileProxy.config.whitelist = ["#{rack_app_url.host}:#{rack_app_url.port}"]
          AgileProxy.config.non_successful_cache_disabled = true
        end

        it 'should not cache non-successful response when enabled' do
          http_error.get('/foo')
          expect(File.exist?(cached_file)).to be_false
        end

        it 'should cache successful response when enabled' do
          assert_cached_url
        end
      end

      context 'non_successful_error_level requests' do
        before do
          rack_app_url = URI(http_error.url_prefix)
          AgileProxy.config.whitelist = ["#{rack_app_url.host}:#{rack_app_url.port}"]
          AgileProxy.config.non_successful_error_level = :error
        end

        it 'should raise error for non-successful responses when :error' do
          # When this config setting is set, the EventMachine running the test servers is killed upon error raising
          # The `raise` is required to bubble up the error to the test running it
          # The Faraday error is raised upon `close_connection` so this can be non-pending if we can do one of the following:
          # 1) Remove the `raise error_message` conditionally for this test
          # 2) Restart the test servers if they aren't running
          # 3) Change the test servers to start/stop for each test instead of before all
          # 4) Remove the test server completely and rely on the server instantiated by the app
          pending 'Unable to test this without affecting the running test servers'
          expect { http_error.get('/foo') }.to raise_error(Faraday::Error::ConnectionFailed)
        end
      end
    end
    context 'disabled' do
      before { AgileProxy.config.persist_cache = false }

      it 'shouldnt persist' do
        http.get('/foo')
        expect(File.exist?(cached_file)).to be_false
      end
    end
  end

  def assert_noncached_url(url = '/foo')
    r = http.get(url)
    expect(r.body).to eql "GET #{url}"
    expect do
      expect do
        r = http.get(url)
      end.to change { r.headers['HTTP-X-EchoCount'].to_i }.by(1)
    end.to_not change { r.body }
  end

  def assert_cached_url(url = '/foo')
    r = http.get(url)
    expect(r.body).to eql "GET #{url}"
    expect do
      expect do
        r = http.get(url)
      end.to_not change { r.headers['HTTP-X-EchoCount'] }
    end.to_not change { r.body }
  end
end
describe AgileProxy::Server, :type => :integration do
  extend AgileProxy::Test::Integration::RequestSpecHelper
  describe 'Without recording' do
    load_small_set_of_request_specs
    before do
      # Adding non-valid Faraday options throw an error: https://github.com/arsduo/koala/pull/311
      # Valid options: :request, :proxy, :ssl, :builder, :url, :parallel_manager, :params, :headers, :builder_class
      faraday_options = {
          request: {timeout: 10.0}
      }
      faraday_options_with_proxy = faraday_options.merge({
        proxy: { uri: "http://anonymous:password@localhost:#{proxy_port}" }
      })
      @http       = Faraday.new @http_url,  faraday_options_with_proxy
      @https      = Faraday.new @https_url, faraday_options_with_proxy.merge(ssl: { verify: false })
      @http_no_proxy       = Faraday.new @http_url_no_proxy,  faraday_options
      @https_no_proxy      = Faraday.new @https_url_no_proxy, faraday_options.merge(ssl: { verify: false })
      @http_error = Faraday.new @error_url, faraday_options_with_proxy
      @http_error_no_proxy = Faraday.new @error_url, faraday_options_with_proxy
    end
    context 'proxying' do
      context 'HTTP' do
        let!(:http) { @http }
        it_should_behave_like 'a proxy server'
      end
      context 'HTTPS' do
        let!(:http) { @https }
        it_should_behave_like 'a proxy server'
      end
    end
    context 'stubbing' do
      context 'In Proxy Mode' do
        context 'HTTP' do
          let!(:url)  { @http_url }
          let!(:http) { @http }
          it_should_behave_like 'a request stub'
        end

        context 'HTTPS' do
          let!(:url)  { @https_url }
          let!(:http) { @https }
          it_should_behave_like 'a request stub'
        end
      end
      #Server mode only supports http - no real point for https at the moment
      context 'In Server Mode' do
        context 'HTTP' do
          let!(:url)  { @http_url_no_proxy }
          let!(:http) { @http_no_proxy }
          it_should_behave_like 'a request stub'
        end
      end
    end
  end
  describe 'With recording' do
    load_small_set_of_request_specs recording: true
    before do
      # Adding non-valid Faraday options throw an error: https://github.com/arsduo/koala/pull/311
      # Valid options: :request, :proxy, :ssl, :builder, :url, :parallel_manager, :params, :headers, :builder_class
      faraday_options = {
        proxy: { uri: 'http://recording:password@localhost:3101' },
        request: { timeout: 10.0 }
      }

      @http       = Faraday.new @http_url,  faraday_options
      @https      = Faraday.new @https_url, faraday_options.merge(ssl: { verify: false })
      @http_error = Faraday.new @error_url, faraday_options
    end
    context 'proxying' do
      context 'HTTP' do
        let!(:http) { @http }
        it_should_behave_like 'a proxy server', recording: true
      end
      context 'HTTPS' do
        let!(:http) { @https }
        it_should_behave_like 'a proxy server', recording: true
      end
    end
    context 'stubbing' do
      context 'HTTP' do
        let!(:url)  { @http_url }
        let!(:http) { @http }
        it_should_behave_like 'a request stub', recording: true
      end
      context 'HTTPS' do
        let!(:url)  { @https_url }
        let!(:http) { @https }
        it_should_behave_like 'a request stub', recording: true
      end
    end
  end
end
