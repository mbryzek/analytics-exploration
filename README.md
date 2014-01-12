analytics-exploration
=====================

Currently just a playground to start experimenting with how we might
build an analytics platform for things like sensor data. The basic
idea to explore is around the interfaces between the creation of
metrics and the ability for others to consume those metrics in real
time, contributing new metrics to the system.

View all metrics:
  http://localhost:11000/metrics

View one metric, including sample data:
  http://localhost:11000/metrics/ekg

Scripts to generate sample data:
  script/generate heartrate 60

Create a subscriber:
  script/subscribe

  The concept of a subscriber is that you provide a URL - we will post
  new events to this URL as they arrive. In practice, this would be
  implemented not with http but with a message queue (e.g. kafka).


Running Locally
===============

rackup consumer/consumer-server.ru -p 10000
rackup consumer/echo-server.ru -p 10001

rackup server/data-server.ru -p 11000

script/subscribe heartrate "http://localhost:10000/events"
script/subscribe ekg "http://localhost:10000/events"
script/subscribe heartattack "http://localhost:10001/events"

script/generate heartrate 60
script/generate ekg 10


Dependencies
============
gem install cuba
gem install json
