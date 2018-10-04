component {

	property name="disqusAuthService" inject="disqusAuthService";

	public any function auth( event, prc, rc, args={} ) {
		var returnUrl = event.buildAdminLink( linkTo="disqus.authorise" );
		var authUrl   = disqusAuthService.getAuthUrl();

		setNextEvent( url=authUrl );
	}

	public any function authorise( event, prc, rc, args={} ) {
		if ( !len( rc.code ?: "" ) ) {
			event.notFound();
		}

		var result = disqusAuthService.getOAuthToken( responseKey=rc.code );
		_processAuthResult( event, result );
	}

	public any function resetToken( event, prc, rc, args={} ) {
		disqusAuthService.deleteAccessToken();
		auth( argumentCollection=arguments );
	}

	public any function refreshToken( event, prc, rc, args={} ) {
		var accessToken = disqusAuthService.getStoredAccessToken();

		if( !len( accessToken.refresh_token ) ){
			event.renderData( type="json", data={ error="Invalid refresh token" } );
			return;
		}

		var result = disqusAuthService.refreshOAuthToken( refreshToken=accessToken.refresh_token );
		_processAuthResult( event, result );
	}


	private any function _processAuthResult( required event, required result ) {
		disqusAuthService.saveAccessToken( result );

		if ( isStruct( result ) && result.keyExists( "access_token" ) ) {
			event.renderData( type="json", data=result );
		} else if ( isStruct( result ) && result.keyExists( "error" ) ) {
			event.renderData( type="json", data=result );
		} else {
			event.renderData( type="json", data={ error=true, message="Authorisation failed" } )
		}
	}

}