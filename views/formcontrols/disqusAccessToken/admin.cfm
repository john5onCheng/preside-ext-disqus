<cfscript>
	accessToken = args.accessToken ?: {};
	redirectUri = args.redirectUri ?: "";
</cfscript>

<cfoutput>
	<cfif len( accessToken.access_token ?: "" )>
		<p class="alert alert-success">
			Access is currently authorised by #accessToken.username# and expires at #DateTimeFormat( accessToken.expires, "d mmm yyyy HH:nn" )#
		</p>
		<p>
			<a target="_blank" class="btn btn-info" href="#event.buildAdminLink( linkTo="disqus.refreshToken" )#">Refresh token</a>
			<a target="_blank" class="btn btn-danger" href="#event.buildAdminLink( linkTo="disqus.resetToken" )#">Reset token</a>
		</p>
	<cfelse>
		<p>
			<a target="_blank" class="btn btn-info" href="#event.buildAdminLink( linkTo="disqus.auth" )#">Authorise access to Disqus API</a>
		</p>
	</cfif>

	<p>
		Callback URI is <code>#redirectUri#</code>
	</p>
</cfoutput>

