require 'em-synchrony'
require 'spec_helper'
describe AgileProxy::Response do
  it 'Should have many requests ' do
    expect(subject).to have_many(:request_specs)
  end
  it 'Should serialize the headers in json format' do
    expect(subject).to serialize(:headers)
  end
  describe 'With a configured delay' do
    before :each do
      subject.delay = 0.5
      subject.content = 'Test'
      subject.content_type = 'text/plain'
    end
    it 'Should respond with a delay using the Em::Synchrony.sleep method' do
      expect(EventMachine::Synchrony).to receive(:sleep).with(0.5)
      expect(subject.to_rack({}, {}, '')).to eql([200, { 'Content-Type' => 'text/plain', 'Cache-Control' => 'no-store' }, ['Test']])
    end

  end
  describe 'Using templates' do
    describe 'Using text' do
      before :each do
        subject.is_template = true
        subject.content = 'Hello {{name}}'
        subject.content_type = 'text/plain'
      end
      it 'Should pass the params to the template and the output should be correct' do
        expect(subject.to_rack({ name: 'World' }, {}, '')).to eql([200, { 'Content-Type' => 'text/plain', 'Cache-Control' => 'no-store' }, ['Hello World']])
      end
      it 'Should deal with if a parameter is missing' do
        expect(subject.to_rack({}, {}, '')).to eql([200, { 'Content-Type' => 'text/plain', 'Cache-Control' => 'no-store' }, ["Hello "]])
      end
    end
  end

end
