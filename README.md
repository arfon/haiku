arXiv Haiku Zen
======

Accidental haiku, auto-generated from the arXiv from http://arxiv.org/list/astro-ph/new, currated for their zen-like properties by [http://twitter.com/arfon](@arfon) and posted at http://zen.arfon.org


Built as part of the [Science Hack Day (SF edition) 2014](http://sf.sciencehackday.org/)

## Why does this exist?

Because ankle bracelets are embarrassing, demoralising and often more than is required for the monitoring of a youth offender's location. The idea here is that via simple Instagram updates (selfie anyone?) with location information it should be possible to keep track of the location of an individual who is out in the community on parole.

This Sinatra-based application [receives pushes](http://instagram.com/developer/realtime/) from the Instagram API and then aggregates this information for a collection of users. 

A task is then run every [~10 minutes](https://github.com/arfon/em-youth-api/blob/master/worker.rb) and if it's been more than an hour since the last check in then the user is reminded via an SMS that they need to post an update. At two hours since check in they are warned again (and further action could be taken).

## Setup

Heroku is your friend with a [MongoHQ addon](https://addons.heroku.com/mongohq) and the [Heroku scheduler](https://addons.heroku.com/scheduler) to run the [background worker](https://github.com/arfon/haiku/blob/master/runner.rb). There's a bunch of environment variables you need to configure:


```
ACCESS_TOKEN:        twitter-access-token
ACCESS_TOKEN_SECRET: twitter-access-token-secret
CONSUMER_KEY:        twitter-consumer-key
CONSUMER_SECRET:     twitter-consumer-secret
MONGOHQ_URL:         mongodb://...
PASSWORD:            review_url_password
USERNAME:            review_url_username

```

## Prior art

Inspired by: 

- https://github.com/dfm/arxiv-poet
- https://github.com/jnxpn/haiku_generator

