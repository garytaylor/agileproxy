require 'spec_helper'

describe AgileProxy::Handler do
  let(:handler) { Class.new { include AgileProxy::Handler }.new }
  it '#handle_request raises an error if not overridden' do
    expect(handler.call(nil)).to eql([500, {}, 'The handler has not overridden the handle_request method!'])
  end
end
