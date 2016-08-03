# Sample config to test OpenIG

This gets mounted on /var/openig/config 


Routes

/* default - default OpenIG page 

/openid - tests OIDC with Google.
You need to edit config/routes/07-openid.json with your
Google application clientId / clientSecret. The credentials
checked in to git are *not* active and will not work. 

To test this, go to 

http://your-k8s-cluster-ingress/openid 

It will trigger a redirect to Google for authentication, and then
a redirect back to the /openid/callback.  If authentication
is succesful you will see user info from Google.


The hostname of the IG server will be printed on the /openid page
as well. This lets yous see if JWTSession cookies are working OK. 

