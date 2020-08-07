/**
 * @nolabel    true
 * @versioned  false
 */

component {
	property name="api_key"       type="string" dbtype="varchar";
	property name="secret_key"    type="string" dbtype="varchar";
	property name="username"      type="string" dbtype="varchar";
	property name="access_token"  type="string" dbtype="varchar";
	property name="refresh_token" type="string" dbtype="varchar";
	property name="expires"       type="date"   dbtype="datetime";
}