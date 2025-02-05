# README

Weather APP

Things you may want to cover:

## Ruby version
This app requires ruby 3.2 due to the use of the newly introduced Data object, however this could easily be swapped out for Struct and support version of ruby that support rails 7.

## TODOS
* Add testing. I would have used RSpec. The WeatherService class is a prime candidate for testing. Making sure to mock out the API calls as well.

* Better error checking in general. The various API calls could use more robust error checking. Geolocation especially just assumes the address is valid and the call succeeded.

* TimeZone handling: The current handling of timezones makes it so the times displayed will be in system time, i.e. the time of the system running the app. This is not correct for when the app would be deployed. It should most likely be displayed in the time of the location of the forecast. This seems to be standard for other weather apps. At the very least it should be in the user's time.

* APP relies on cache as a source of persistence. This is not ideal. This was done so that the default rails redirect to a show would work. There are other strategies that could be discussed. One of which is to just do it all on one page and not do a redirect.