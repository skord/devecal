# devecal

devecal is a web application that acts as a converter your EVE Online calendar (in XML format) to an ical format calendar you can download or (better) subscribe to in something like iCal, Outlook, etc.

It is a Ruby language program written using the Sinatra framework and expressly designed to run on [Heroku](http://heroku.com). It takes advantage of Heroku's Varnish cache system to avoid running into API limits with EVE's servers, so should you decide to deploy this anywhere other than Heroku, you need to take this into account. 

Why would you want to run your own version of this rather than use [the one I've put up](http://evecal.heroku.com)? I don't know, but whatever works. 

No, I can't remember why I called this devecal. No clue.

### Contributing

Fork on Bitbucket, open an issue explaining wtf changed and why and create a pull request.

