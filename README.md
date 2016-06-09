#Preside Extension - Disqus

#Disqus extension basic setup ( Assume you have done setup Disqus account and the app )
1.) Setup Disqus API setting in Preside admin > Setting > Disqus API
Fill in the required field. To get the public key you need to add remote domain in your Disqus account.
https://disqus.com/api/applications/

2.) Add this line to your view
renderView( view = 'disqus/index', args = { showDisqus = showDisqus ?: false } )
showDisqus is an argument option for you to turn it on / off for particular page

3.) Add this line to your page handler
if( isLoggedIn() ){
	var userDetails = getLoggedInUserDetails();
	prc.disqusLoginToken   = disqusService.createLoginToken(
		  id       = userDetails.id
		, username = userDetails.display_name
		, email    = userDetails.email_address
	);
}

#SSO setup checklist
1.) Contact Disqus to enable SSO in your Disqus account. To do this request, you need to be the primary moderator.
https://disqus.com/support/?article=contact_SSO

2.) A new link will appear in your disqus Application API page after Disqus team has enable the SSO for you.
Visit the SSO link and setup the domain and slug.
https://disqus.com/api/sso/

3.) Go to your application > setting > select SSO domain.
https://disqus.com/api/applications/
