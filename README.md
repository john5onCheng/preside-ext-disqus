# Preside Extension - Disqus

## Disqus extension basic setup
*This assumes you have setup the Disqus account and application*

1. Setup Disqus API setting in *Preside admin > Setting > Disqus API*.
	Fill in the required field. To get the public key you need to add remote domain in your Disqus account.
	https://disqus.com/api/applications/

2. Add this line to your view:
	```
	renderView( view="disqus/index", args={ disqusIdentifier=contentId, showDisqus=true } )
	```
	...where:

	* `showDisqus` is an argument option for you to turn it on / off for particular page
	* `disqusIdentifier` is an ID to permanently identify the current page or resource, so Disqus will maintain a link to the correct discussion even if the URL changes. Use the page or record ID for this.

3. Add this code to your page handler:
	```
	if ( isLoggedIn() ) {
		var userDetails = getLoggedInUserDetails();
		prc.disqusLoginToken = disqusService.createLoginToken(
			  id       = userDetails.id
			, username = userDetails.display_name
			, email    = userDetails.email_address
		);
	}
	```

## SSO setup checklist
1. Contact Disqus to enable SSO in your Disqus account. To do this request, you need to be the primary moderator.
	https://disqus.com/support/?article=contact_SSO

2. A new link will appear in your disqus Application API page after Disqus team has enable the SSO for you.
	Visit the SSO link and setup the domain and slug.
	https://disqus.com/api/sso/

3. Go to your *Application > Setting > Select SSO domain*.
	https://disqus.com/api/applications/


## OAuth and the Disqus API
The extension now supports connection to the Disqus API. To enable this, you will need to go to *Preside admin > Setting > Disqus API* and click the "Authorise access to Disqus API" button. Log in at Disqus, and the token should be activated.

Once this is done, you can make use of calls to the Disqus API. Currently, these are the available actions:

* `disqusService.closeThread( threadIdentifier=id )` - closes a discussion thread to new comments, while still displaying previously submitted ones
* `disqusService.openThread( threadIdentifier=id )` - opens up a closed discussion thread to allow comments
* `disqusService.removeThread( threadIdentifier=id )` - completely delete a discussion thread from Disqus

The `id` passed in here is the id passed previously as the `disqusIdentifier` - the unique identifier of the page or content.

Alternatively, you can pass `threadId=id` as the argument; in this case the id is Disqus's internal id for the thread, if you know it. This is likely to have been returned by another (as yet unimplemented) API call.