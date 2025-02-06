# README

Weather APP

## Ruby version
This app requires ruby 3.2 due to the use of the newly introduced Data object, however this could easily be swapped out for Struct and support versions of ruby that support rails 7.

## TODOS
* Add more robust system tests.

* TimeZone handling: The current handling of timezones makes it so the times displayed are in the timezone of the system running the server. This seems to be a quirk of the Openweather API. It should most likely be displayed in the time of the location of the forecast. This seems to be standard for other weather apps.

* APP relies on cache as a source of persistence. This is not ideal. This was done so that the default rails redirect to a show would work. There are other strategies that could be discussed. One of which is to just do it all on one page and not do a redirect.