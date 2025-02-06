# README

Weather APP

## Ruby version
This app requires ruby 3.2 due to the use of the newly introduced Data object, however this could easily be swapped out for Struct and support any version of ruby that support rails 7.

## Setup
Set api key required for openweather API

`rails credentials:edit`

Add:

`openweather_api_key: api_key_here`

The api key can be obtained after signing up on: https://openweathermap.org

and then subscribing to the One Call API plan here: https://openweathermap.org/price

This plan is free up to 1,000 API calls a day, so perfect for testing.

`bundle install`

Enable caching locally:

`rails dev:cache`

Run server

`rails server`

visit localhost:3000

Run specs

`rspec`

The specs are all stubbed out so they don't hit the geolocation or weather forcasting service.

As there is currently no use of javascript in the app, the system tests all use rack-test so they don't require any selenium browser drivers.

## TODOS
* Add more robust system tests.

* TimeZone handling: The current handling of timezones makes it so the times displayed are in the timezone of the system running the server. This seems to be a quirk of the Openweather API. It should most likely be displayed in the time of the location of the forecast. This seems to be standard for other weather apps.

* APP relies on cache as a source of persistence. This is not ideal. This was done so that the default rails redirect to a show would work. There are other strategies that could be discussed. One of which is to just do it all on one page and not do a redirect.

* Clearly the UI could use some improvment. Probably the most useful thing would be to add some sort of autocomplete for users when they are filling in their address.