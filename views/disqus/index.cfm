<cfscript>
	param name="args.showDisqus"       default=true;
	param name="args.disqusUrl"        default=( prc.canoncialUrl     ?: "" );
	param name="args.disqusIdentifier" default=( prc.disqusIdentifier ?: "" );
	param name="args.disqusLoginToken" default=( prc.disqusLoginToken ?: "" );

	disqusUrlExists        = !isEmpty( args.disqusUrl        );
	disqusIdentifierExists = !isEmpty( args.disqusIdentifier );
	disqusLoginTokenExists = !isEmpty( args.disqusLoginToken );
	disqusAPIKey           = getSystemSetting( "disqus", "api_key"       , '' );
	isSSOEnabled           = getSystemSetting( "disqus", "enable_sso"    , false );
	disqusSSOSiteName      = getSystemSetting( "disqus", "sso_site_name" , '' );
	disqusSSOButton        = getSystemSetting( "disqus", "sso_button"    , '' );
	disqusSSOIcon          = getSystemSetting( "disqus", "sso_icon"      , '' );
	disqusSSOLoginURL      = getSystemSetting( "disqus", "sso_url"       , '' );
	disqusSSOLogoutURL     = getSystemSetting( "disqus", "sso_logout"    , '' );
	disqusSSOWidth         = getSystemSetting( "disqus", "sso_width"     , '800' );
	disqusSSOHeight        = getSystemSetting( "disqus", "sso_height"    , '400' );

	disqusSSOLoginURL      = !isEmpty( disqusSSOLoginURL )  ? event.buildLink( id = disqusSSOLoginURL  ) : event.buildLink( page   = 'login' );
	disqusSSOLogoutURL     = !isEmpty( disqusSSOLogoutURL ) ? event.buildLink( id = disqusSSOLogoutURL ) : event.buildLink( linkTo = 'login.logout' );
</cfscript>
<cfoutput>
<cfif args.showDisqus>
<div id="disqus-wrap" class="disqus-wrap">
	<div id="disqus_thread"></div>
	<script>
		<cfif disqusUrlExists || disqusIdentifierExists || disqusLoginTokenExists>
			var disqus_config = function() {
				<cfif disqusUrlExists>
					this.page.url            = "#args.disqusUrl#";
				</cfif>
				<cfif disqusIdentifierExists>
					this.page.identifier     = "#args.disqusIdentifier#";
				</cfif>
				<cfif disqusLoginTokenExists && isSSOEnabled == 1>
					this.page.remote_auth_s3 = "#args.disqusLoginToken#";
					this.page.api_key        = "#disqusAPIKey#";
				</cfif>
				<cfif isSSOEnabled == 1>
				 	this.sso = {
						  name   : "#disqusSSOSiteName#"
						, button : "#event.buildLink( assetId = disqusSSOButton )#"
						, icon   : "#event.buildLink( assetId = disqusSSOIcon )#"
						, url    : "#disqusSSOLoginURL#"
						, logout : "#disqusSSOLogoutURL#"
						, width  : "#disqusSSOWidth#"
						, height : "#disqusSSOHeight#"
					};
				</cfif>
			};
		</cfif>


		(function() { // DON'T EDIT BELOW THIS LINE
			var d = document, s = d.createElement('script');
			s.src = '//#getSystemSetting( "disqus", "short_name", "" )#.disqus.com/embed.js';
			s.setAttribute('data-timestamp', +new Date());
			(d.head || d.body).appendChild(s);
		})();
	</script>
	<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>
</div>
</cfif>
</cfoutput>