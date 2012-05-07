# RTFM - Real Time Foto Moderator

Real Time Foto Moderator (RTFM) is Crowdsourced Image Moderation, learn more at http://crowdflower.com/rtfm.  This gem is a simple wrapper for interacting with the API.  Keep your app clean!

## Usage

```shell
gem install rtfm
```

```ruby
require 'rubygems'
require 'rtfm'

RTFM.api_key = "a1b2c3d4e5f6g7h8i9j0..."
#moderate_image accepts an optional metadata hash
res = RTFM.moderate_image("http://mysite.com/images/moderateme.jpg", {:id => 123})
RTFM.retrieve_image(res["image"]["id"])
```

## Exceptions

All exceptions thrown by the gem itself inherit from `RTFM::Error`.  Below are the possible exceptions:

* RateLimitError - (rate limit exceeded)
* PaymentError - (account is out of money)
* AccountError - (your account is not authorized for this service)
* AuthenticationError - (your API key is invalid)
* InvalidRequestError - (one of your parameters is invalid, usually url)
* APIError - (a non 200 response code was returned, see the docs)
* APIConnectionError - (a network error occured)

## Webhook example

We've also included an example Sinatra server to consume webhooks from RTFM.  You can find it at https://github.com/dolores/rtfm-ruby/tree/master/examples

# Acknowledgements

The implementation of this wrapper was inspired heavily by Stripes Ruby implementation (https://github.com/stripe/stripe-ruby).  Thanks to Ross Boucher & Greg Brockman for bending RestClient to their will.

# Copyright

Copyright (c) 2012 CrowdFlower. See LICENSE.txt for
further details.

