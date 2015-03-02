require 'flavour_saver'
require 'flavour_saver/runtime'
module AgileProxy
  #
  # = The associated response for the RequestSpec
  #
  # An instance of this class is expected to be stored alongside every RequestSpec.
  #
  # It is responsible for the following :-
  #
  # 1. Retrieving response
  # 2. Persisting responses
  # 3. Providing a 'rack' ouput of the response
  # 4. Convenient setters for code, body and content_type
  # 5. Template parsing
  class Response < ActiveRecord::Base
    PROTECTED_HEADERS = ['Content-Type']
    has_many :request_specs
    serialize :headers, JSON
    # A convenient setter for the content_type within the header
    # @param val [String] The content type
    def content_type=(val)
      write_attribute(:content_type, val)
      headers.merge!('Content-Type' => val)
      val
    end
    # Provides the response as a 'rack' response
    #
    # If the response is a template (by specifying is_template as true), the output will
    # have its template values parsed and replaced with
    # data from the input_params, input_headers and input_body
    # Otherwise, the body of the output is sent as is.
    # @param input_params [Hash] The input parameters as a hash
    # @param _input_headers [Hash] The input headers as a hash
    # @param _input_body [String] The input body
    # @return [Array] A 'rack' response array (status, headers, body)
    def to_rack(input_params, _input_headers, _input_body)
      output_headers = headers.clone
      output_content = content
      output_status_code = status_code
      if is_template
        data = OpenStruct.new input_params
        template = Tilt['handlebars'].new { output_content }
        output_content = template.render data
      end
      EventMachine::Synchrony.sleep(delay) if delay > 0
      [output_status_code, output_headers, [output_content]]
    end
  end
end
