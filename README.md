analytics-exploration
=====================

Currently just a playground to start experimenting with how we might
build an analytics platform for things like sensor data. The basic
idea to explore is around the interfaces between the creation of
metrics and the ability for others to consume those metrics in real
time, contributing new metrics to the system.

View all metrics:
  http://localhost:9292/metrics

View one metric, including sample data:
  http://localhost:9292/metrics/ekg

Generate some sample data:
  script/generate heartrate 100 60

Create a subscriber:
  script/subscriber

  The concept of a subscriber is that you provide a URL - we will post
  new events to this URL as they arrive. In practice, this would be
  implemented not with http but with a message queue (e.g. kafka).


rackup consumer/consumer-server.ru -p 10000
