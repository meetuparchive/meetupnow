Meetup Now v0.1

REQUIRED TO RUN:
Apache Ant
Google AppEngine API

To run, first make sure this directory is in the same directory as the google APPENGINE API folder.

In order to register your copy with your Meetup Dev profile, first login/register to Meetup in order to recieve an API key. The key can be found here:
http://www.meetup.com/meetup_api/key/
When you have this, you must next run the command
ant register
and input the API key when prompted.  This will allow you to create/use the RegDev object which can sign API requests on your behalf.

When this is done, use the command
ant runserver
to run a server on port 8080 on your computer. Then, to view the site, go to 'http://localhost:8080/' in your web browser.

To compile without running, use the command
ant compile

If you have any questions regarding our code, please email jake@meetup.com

6/28 UPDATE: In order to make signed non-OAuth calls, upon any fresh clone or dl of this package, run 'ant register' to input your meetup API key (get one at http://www.meetup.com/meetup_api/key/)

6/23 UPDATE: Check out a live version of our software running at: http://jake-meetup-test.appspot.com