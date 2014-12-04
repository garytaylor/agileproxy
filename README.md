# agile-proxy

A proxy server intended for use during development or in integration test environments such as selenium.

## Overview

The proxy sits between the browser and the server. You can either configure the browser manually to do so
or via the selenium API if you are using selenium.
Requests can simply pass through, or be intercepted in some way.
By default, all requests pass through untouched.
The magic then happens when the developer informs the proxy how to respond to various requests.  This
can either be done using a JSON API or using the Web Based User Interface.

Requests are matched either exactly (for example 'http://www.google.com'), using regex's, using router pattern matching
(similar to rails or other MVC frameworks).

Response bodies can be set along with any header values, status code etc..

Client drivers are available for the following languages :-

ruby
javascript (node.js)

And will soon be available for :-

javascript (browser based)
java
scala
python

## Example Client Code
To any puffing-billy users, this will look familiar as this project is inspired by puffing-billy.

```ruby
it 'should stub google' do
  proxy.stub('http://www.google.com/').and_return(:text => "I'm not Google!")
  visit 'http://www.google.com/'
  page.should have_content("I'm not Google!")
end
```

## Installation

When integrating this gem into your test suite :-

Add this line to your application's Gemfile:

    gem 'agile-proxy'

And then execute:

    $ bundle

Or if you want to use it as a standalone proxy server with a web user interface:

    $ gem install agile-proxy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

1. LOTS

