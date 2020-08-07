/**
 * @presideService
 * @singleton
 */

component {

// CONSTRUCTOR
	 public any function init() {
		_setDisqusSettings();

		return this;
	}

	public string function getAccessToken() {
		var accessToken = getStoredAccessToken();

		if ( isDate( accessToken.expires ) && accessToken.expires < now() ) {
			accessToken = refreshOAuthToken( accessToken.refresh_token );
			var success = saveAccessToken( accessToken );

			if ( !success ) {
				return "";
			}
		}

		return accessToken.access_token;
	}

	public boolean function isValidAccessToken( required any accessToken ) {
		return len( accessToken.username      ?: "" )
		    && len( accessToken.access_token  ?: "" )
		    && len( accessToken.refresh_token ?: "" )
		    && isNumeric( accessToken.expires_in ?: "" );
	}

	public struct function getStoredAccessToken() {
		var settings    = _getDisqusSettings();
		var accessToken = $getPresideObject( "disqus_access_token" ).selectData(
			  filter       = { api_key=settings.api_key ?: "", secret_key=settings.secret_key ?: "" }
			, selectFields = [ "username", "access_token", "refresh_token", "expires" ]
		);

		for ( var a in accessToken ) {
			return a;
		}

		return { username="", access_token="", refresh_token="", expires="" };
	}

	public boolean function saveAccessToken( required any accessToken ) {
		if ( !isValidAccessToken( arguments.accessToken ) ) {
			return false;
		}

		var dao      = $getPresideObject( "disqus_access_token" );
		var settings = _getDisqusSettings();
		var existing = dao.selectData(
			  filter       = { api_key=settings.api_key, secret_key=settings.secret_key }
			, selectFields = [ "id" ]
		);
		var data     = {
			  api_key       = settings.api_key
			, secret_key    = settings.secret_key
			, username      = arguments.accessToken.username
			, access_token  = arguments.accessToken.access_token
			, refresh_token = arguments.accessToken.refresh_token
			, expires       = dateAdd( "s", arguments.accessToken.expires_in - 60, now() )
		};

		if ( existing.recordcount ) {
			dao.updateData( id=existing.id, data=data );
		} else {
			dao.insertData( data=data );
		}

		accessToken.success = true;
		return true;
	}

	public void function deleteAccessToken() {
		var settings = _getDisqusSettings();
		$getPresideObject( "disqus_access_token" ).deleteData(
			filter = { api_key=settings.api_key, secret_key=settings.secret_key }
		);
	}

	public any function getAuthUrl() {
		var settings = _getDisqusSettings();
		var params   = [
			  "scope=read,write,admin"
			, "response_type=code"
			, "client_id=" & settings.api_key
			, "redirect_uri=" & getRedirectUri()
		];

		return settings.authorise_url & "?" & params.toList( "&" );
	}


	public any function getOAuthToken( required string responseKey ) {
		var settings = _getDisqusSettings();
		var result   = _sendRequest(
			  uri            = settings.access_token_url
			, method         = "POST"
			, params         = {
				  code          = arguments.responseKey
				, grant_type    = "authorization_code"
				, client_id     = settings.api_key
				, client_secret = settings.secret_key
				, redirect_uri  = getRedirectUri()
			  }
		);

		return result;
	}

	public any function refreshOAuthToken( required string refreshToken ) {
		var settings = _getDisqusSettings();
		var result           = _sendRequest(
			  uri            = settings.access_token_url
			, method         = "POST"
			, params         = {
				  refresh_token = arguments.refreshToken
				, grant_type    = "refresh_token"
				, client_id     = settings.api_key
				, client_secret = settings.secret_key
				, redirect_uri  = getRedirectUri()
			}
		);

		return result;
	}

	public string function getRedirectUri() {
		return $getRequestContext().buildLink( linkTo="admin.disqus.authorise" );
	}




//PRIVATE METHODS
	private any function _sendRequest(
		  required string  uri
		,          string  method         = "GET"
		,          struct  params         = {}
		,          boolean refreshedToken = false
	) {
		var settings       = _getDisqusSettings();
		var result         = "";
		var requestTimeout = 10;
		var refreshedToken = isBoolean( arguments.refreshedToken ?: "" ) && arguments.refreshedToken;
		var paramType      = arguments.method == "GET" ? "url" : "formfield";

		http method=arguments.method url=arguments.uri timeout=requestTimeout result="result" {
			for( var param in arguments.params ) {
				httpparam name=param type=paramType value=arguments.params[ param ];
			}
		}

		if( isJson( result.fileContent ?: "" ) ) {
			var resultContent = DeserializeJson( result.fileContent );

			// If token expired, refresh token and try again
			// if( !refreshedToken && Len( resultContent.int_err_code ?: "" ) && CompareNoCase( resultContent.int_err_code, "InvalidToken" ) == 0 ){
			// 	var duplicateArg            = duplicate( arguments );
			// 	var headerAuthorization     = arguments.header[ "Authorization" ] ?: "";
			// 	duplicateArg.refreshedToken = true

			// 	var newAccessToken = autoRefreshOAuthToken();

			// 	if( Len( newAccessToken ) && findNoCase( "oauth_token", headerAuthorization ) != 0 ){
			// 		duplicateArg.header[ "Authorization" ] = "OAuth oauth_token=#newAccessToken#";
			// 		return _sendRequest( argumentCollection=duplicateArg );
			// 	}
			// } else {
				return resultContent;
			// }
		}

		return result;
	}



// SETTERS & GETTERS
	private any function _getDisqusSettings() {
		return _disqusSettings;
	}
	private void function _setDisqusSettings() {
		_disqusSettings = $getPresideCategorySettings( "disqus" );
	}

}