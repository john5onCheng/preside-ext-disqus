<cfscript>
	param name="args.showDisqus" default=true;

	canoncialURLExists     = !isEmpty( prc.canoncialURL     ?: '' );
	disqusLoginTokenExists = !isEmpty( prc.disqusLoginToken ?: '' );
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
		<cfif canoncialURLExists || disqusLoginTokenExists >
			var disqus_config        = function () {
				 <cfif canoncialURLExists>
					this.page.url        = "#prc.canoncialURL#";
					this.page.identifier = "#prc.disqusIdentifier#";
				</cfif>
				<cfif disqusLoginTokenExists && isSSOEnabled>
					this.page.remote_auth_s3 = "#prc.disqusLoginToken#";
					this.page.api_key        = "#disqusAPIKey#";
				</cfif>
			};
		</cfif>
		<cfif isSSOEnabled>
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