/**
 * @presideService
 * @singleton
 */

component {

// CONSTRUCTOR
	/**
	 * @disqusAPICache.inject         cachebox:template
	 * @disqusAuthService.inject      disqusAuthService
	 */
	 public any function init( required any disqusAPICache, required any disqusAuthService ) {
		_setDisqusAPICache( arguments.disqusAPICache );
		_setDisqusAuthService( arguments.disqusAuthService );
		_setDisqusSettings();

		return this;
	}

//PUBLIC METHODS
	/**
	 *  Method name : posts/listPopular
	 *  Reference   : https://disqus.com/api/docs/posts/listPopular/
	 */
	public any function getListPopular( numeric limit=10, string interval="90d"	) {
		var result = _callApi(
			  endpoint = "threads/listPopular.json"
			, params   = {
				  interval = arguments.interval
				, limit    = arguments.limit
				, forum    = _getDisqusSettings().short_name
			}
		);

		if ( result.success ) {
			return result.response;
		} else {
			return [];
		}
	}

	/**
	 *  Method name      : threads/open
	 *  Reference        : https://disqus.com/api/docs/threads/open/
	 *  threadId         : Disqus's internal ID of the thread. Use this OR threadIdentifier
	 *  threadIdentifier : The unique ID of the page or content passed when embedding the Disqus comments. Use this OR threadId
	 */
	public boolean function openThread( string threadId="", string threadIdentifier="" ) {
		var params = {};
		if ( len( arguments.threadId ) ) {
			params[ "thread" ] = arguments.threadId;
		} else if ( len( arguments.threadIdentifier ) ) {
			params[ "thread:ident" ] = arguments.threadIdentifier;
		} else {
			return false;
		}

		var result = _callApi(
			  method       = "POST"
			, endpoint     = "threads/open.json"
			, authenticate = true
			, params       = params
		);

		return result.success;
	}

	/**
	 *  Method name      : threads/close
	 *  Reference        : https://disqus.com/api/docs/threads/close/
	 *  threadId         : Disqus's internal ID of the thread. Use this OR threadIdentifier
	 *  threadIdentifier : The unique ID of the page or content passed when embedding the Disqus comments. Use this OR threadId
	 */
	public boolean function closeThread( string threadId="", string threadIdentifier="" ) {
		var params = {};
		if ( len( arguments.threadId ) ) {
			params[ "thread" ] = arguments.threadId;
		} else if ( len( arguments.threadIdentifier ) ) {
			params[ "thread:ident" ] = arguments.threadIdentifier;
		} else {
			return false;
		}

		var result = _callApi(
			  method       = "POST"
			, endpoint     = "threads/close.json"
			, authenticate = true
			, params       = params
		);

		return result.success;
	}

	/**
	 *  Method name      : threads/remove
	 *  Reference        : https://disqus.com/api/docs/threads/remove/
	 *  threadId         : Disqus's internal ID of the thread. Use this OR threadIdentifier
	 *  threadIdentifier : The unique ID of the page or content passed when embedding the Disqus comments. Use this OR threadId
	 */
	public boolean function removeThread( string threadId="", string threadIdentifier="" ) {
		var params = {};
		if ( len( arguments.threadId ) ) {
			params[ "thread" ] = arguments.threadId;
		} else if ( len( arguments.threadIdentifier ) ) {
			params[ "thread:ident" ] = arguments.threadIdentifier;
		} else {
			return false;
		}

		var result = _callApi(
			  method       = "POST"
			, endpoint     = "threads/remove.json"
			, authenticate = true
			, params       = params
		);

		return result.success;
	}

//CACHED PUBLIC METHODS
	public array function getCachedPopularPostList(
		  numeric limit    = 10
		, string  interval = "90d"
	) {
		var cacheKey    = "disqusPopularPostList" & serializeJSON( arguments );
		var cachedValue = _getDisqusAPICache().get( cacheKey );

		if ( !IsNull( cachedValue )  ) {
			return cachedValue;
		}

		var listPopular = getListPopular( limit=arguments.limit, interval=arguments.interval );

		_getDisqusAPICache().set( cacheKey, listPopular );

		return listPopular;
	}

//SSO HELPERS
	/**
	 *  ID        : Any unique user ID associated with that account within your user database.
	 *  userName  : The displayed name for that account
	 *  email     : The registered email address for that account
	 *  avatar    : A link to that user's avatar. Note: URL must be less than 200 characters.
	 *  url       : A link to the user's website
	 */
	public string function createLoginToken(
		  required string ID
		, required string userName
		, required string email
		,          string avatar     = ""
		,          string url        = ""
	) {
		var loggedInUser = {
			  id       = arguments.ID
			, username = arguments.userName
			, email    = arguments.email
			, avatar   = left( arguments.avatar, 200 )
			, url      = arguments.url
		}

		var unixTimeStamp = DateDiff( "s", CreateDate( 1970,1,1 ), dateConvert( "local2utc", now() ) );
		var userData      = SerializeJSON( loggedInUser );
		var stgMessage    = ToBase64( userData ) & " " & unixTimeStamp;
		var stgSignature  = HMAC( stgMessage, _getDisqusSettings().secret_key, "HmacSHA1"  );

		return ToBase64( userData ) & " " & stgSignature & " " & unixTimeStamp;
	}


//PRIVATE METHODS
	private any function _callApi(
		  required string  endpoint
		,          struct  params
		,          string  method       = "GET"
		,          boolean authenticate = false
	){
		var result       = {};
		var response     = "";
		var success      = false;
		var fullEndPoint = _getDisqusSettings().end_point & arguments.endpoint;
		var forum        = _getDisqusSettings().short_name;
		var api_key      = _getDisqusSettings().api_key;
		var secret_key   = _getDisqusSettings().secret_key;
		var access_token = arguments.authenticate ? _getDisqusAuthService().getAccessToken() : "";

		try {
			http url=fullEndPoint method=arguments.method result="response" timeout=5 resolveurl=true {
				httpparam name="forum"   value=forum   type="url";
				httpparam name="api_key" value=api_key type="url";
				if ( arguments.authenticate ) {
					httpparam name="api_secret"   value=secret_key   type="url";
					httpparam name="access_token" value=access_token type="url";
				}
				for( var param in arguments.params ) {
					httpparam name=param value=arguments.params[ param ] type="url";
				}
			};
			result         = deserializeJson( response.fileContent );
			result.success = ( result.code ?: "" ) == 0;
		} catch( any e ) {
			result.success = false;
			$raiseError( e );
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

	private any function _getDisqusAPICache(){
		return _disqusAPICache;
	}
	private void function _setDisqusAPICache( required any disqusAPICache ){
		_disqusAPICache = arguments.disqusAPICache;
	}

	private any function _getDisqusAuthService(){
		return _disqusAuthService;
	}
	private void function _setDisqusAuthService( required any disqusAuthService ){
		_disqusAuthService = arguments.disqusAuthService;
	}

}