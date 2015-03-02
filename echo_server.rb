#!/usr/bin/env ruby

require 'goliath'
require 'active_support/core_ext/class/attribute_accessors'
class Echo < Goliath::API
  cattr_accessor :counter
  def response_code
    ENV['STATUS_CODE'] || 200
  end
  def response(env)
    self.counter = counter || 0
    req_body = env['rack.input'].read
    request_info = "#{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
    res_body = request_info
    res_body += "\n#{req_body}" unless req_body.empty?
    self.counter += 1
    [response_code, { 'HTTP-X-EchoServer' => request_info, 'HTTP-X-EchoCount' => "#{counter}" }, res_body]
  end
end