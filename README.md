 [![Build Status](https://travis-ci.org/garytaylor/agileproxy.svg?branch=master)](https://travis-ci.org/garytaylor/agileproxy)
 [![Gem Version](https://badge.fury.io/rb/agile-proxy.svg)](http://badge.fury.io/rb/agile-proxy)
# agile-proxy

A proxy server intended for use during development or in integration test environments such as selenium.

Either the developer or the test suite can constantly change the response from a particular 'route' or URL via
either the built in user interface or using REST calls.  An adapter is currently written for nodejs to provide easy
 access to the REST interface - others are to follow.

So, you may be used to being able to stub methods in your unit tests, you can now stub http requests in your integration
tests too.  It doesn't matter if you are using ruby, nodejs, java, scala ... the list goes on.  As long as your 'HTTP Client'
 (whether its a browser, or some form of programatic access to HTTP) supports a proxy, then you can use this.

This has many uses, the main one that I currently use this for is for developing a user interface when the server side
code is either a work in progress or not developed yet.
Even if you are not into writing integration tests for your UI layer and prefer to just write code and test manually
(which of course I do not recommend, but some people like working that way), then you can go to the user interface
and simply tell the system what you want your fake server to look like -

for example :- "When anything requests http://www.bing.com" then return "A fake bing page".

A particularly poor example, but hopefully demonstrates the idea.

## Overview

The proxy sits between the client (maybe a browser) and the server. You can either configure the browser manually to do so
or via the selenium API if you are writing an integration test using selenium.
Requests can simply pass through, or be intercepted in some way.
By default, all requests pass through untouched.
The magic then happens when the developer informs the proxy how to respond to various requests.  This
can either be done using a JSON API or using the Web Based User Interface.

Requests are matched either exactly (for example 'http://www.google.com'), or using router pattern matching
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
## Support

To discuss issues, goto https://groups.google.com/forum/#!forum/agileproxygem

Or, if you have an issue that you want to report - please use the issues list in this repository

## Installation

    $ gem install agile-proxy

Thats it - all done.

## Starting the server

agile_proxy start 3100

This will start the server with default options on port 3100

## Using The Built In User Interface

Goto http://localhost:3020 in your browser

## Configuring a browser to use the proxy

The proxy url for the default application is

http://public-app-1:password@localhost:3100

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

1. Asserting requests were made to specific urls and that they contained the correct parameters
2. Route matching on URL parameters from the query string
3. Multi Application - The current infrastructure supports it, just need UI support - can already be done using REST

## History
v0.1.8 Added support for plain text params parser - As DWR uses this (and maybe others)

v0.1.9 Plain text params parser bug fixed - now handles params with a key and no value

v0.1.10 Now using dependent: :destroy to tidy up better when all specs for an application are deleted (common occurence)

v0.1.11 Further improved database tidy up.
        AGILE_PROXY_ENV can now set the environment at server startup
        conditions handling improved in routing

v0.1.12 Added a 'Direct' server which is a simple HTTP server that response to the stubs - also allows
        for static dirs to be hosted.

v0.1.13 Upgraded activerecord and other gems to later versions

v0.1.14 - Increased pagination size by default to 50 on stubs until I add the client side code
v0.1.15 - 0.1.17 - No functionality change, these were just to try and please travis
v0.1.18 - Fixed issue with integration test which was showing up now that travis is working again
v0.1.19 - Recordings now record the request spec id.
            Recordings can now be accessed via /request_specs/:request_spec_id/recordings to provide recordings specific to the request spec
v0.1.20 - An individual request spec can now be set to 'record_requests' rather than requiring the whole application to be in record mode which slows down every request
v0.1.21 - Switched to goliath instead of thin.  The gem now installs under jruby as well as other platforms.
v0.1.22 - Reverted 0.1.21 - Integration tests worked fine, but failed in real world scenario - never ending responses from stubs
v0.1.23 - Switched to goliath instead of thin.  The gem now installs under jruby as well as other platforms.
v0.1.24 - Added caching
v0.1.25 - Caching now disabled by default but enabled in config.
            Direct server now functional
v0.1.26 - index.html is now setup as the root of a static dir

