component {

	this.name = "ColdFusionSqlite";
	this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;

	// In order to decouple the ColdFusion application from the physical location of the
	// SQLite databases, we're going to use a per-application mapping.
	this.mappings = {
		"/databases": "/var/www-databases"
	};

}
