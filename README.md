Haiku Zen
======

Accidental haiku, auto-generated from the arXiv from http://arxiv.org/list/astro-ph/new, currated for their zen-like properties by [http://twitter.com/arfon](@arfon) and posted at http://zen.arfon.org


Built as part of the [Science Hack Day (SF edition) 2014](http://sf.sciencehackday.org/)

## Why does this exist?

Why not?

## How does it work?

This Sinatra-based application that once per day pulls all the abstracts from the arXiv with [this script](https://github.com/arfon/haiku/blob/master/runner.rb).

Haiku are generated based on a dictionary and Ruby script here: https://github.com/jnxpn/haiku_generator and listed in a review interface for me to post to Twitter.

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

## Zen

Either follow [@arxivzen](http://twitter.com/arxivzen) on Twitter for your daily dose of Zen or head over to http://zen.arfon.org for a truly magical experience.

![screen shot 2014-10-05 at 1 52 10 pm](https://cloud.githubusercontent.com/assets/4483/4519933/88c0fc38-4cd1-11e4-85a7-e22d3396410d.png)

## Look ma, there's an API!

Kind of.

```
curl -H 'Accept: application/json' http://zen.arfon.org

[
 {"body":"Conditions For The \n Thermal Instability \n To Operate In \n",
  "created_at":"2014-10-05T18:31:10Z",
  "id":"54318e6e43dd37000200000d",
  "status":"published",
  "updated_at":"2014-10-05T18:51:56Z",
  "url":"http://arxiv.org/abs/1410.0397"},
 {"body":"Though This Groundbreaking \n Technical Achievement Will \n Be Its Own Reward \n",
  "created_at":"2014-10-05T18:32:04Z",
  "id":"54318ea443dd37000200002b",
  "status":"published",
  "updated_at":"2014-10-05T19:14:04Z",
  "url":"http://arxiv.org/abs/1404.5623"}
]  

```

## Prior art

Inspired by:

- https://github.com/dfm/arxiv-poet
- https://github.com/jnxpn/haiku_generator
