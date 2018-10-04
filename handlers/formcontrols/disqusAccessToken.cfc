component {
	property name="disqusAuthService" inject="disqusAuthService";

	public string function admin( event, rc, prc, args={} ) {
		args.accessToken = disqusAuthService.getStoredAccessToken();
		args.redirectUri = disqusAuthService.getRedirectUri();

		return renderView( view="formcontrols/disqusAccessToken/admin", args=args );
	}
}
