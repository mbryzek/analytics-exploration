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


TODO

Data Size
=========
10k users
1 years of data
160 MB / user /day
58 GB / year / user

ppg signal
  - rate: 500 hertz
  - normalized reading from 0.000 to 1.000

generate:
  - ppg_signal @ 1 / second
  - ppg_signal @ 1 / minute
  - generate heartrate
     --> some math (peak detection)
     --> publish this at 1 / second (trailing 3 seconds)
  - generate heartrate / minute
  - generate heartrate / hour
  - generate heartrate / day
  - generate heartrate / week
  - generate heartrate / month
  - generate heartrate / year

display heartrate for multiple users
  - live per second view
  - view last couple months


Then we invent a new algorithm to compute heartrate... think through
what happens



