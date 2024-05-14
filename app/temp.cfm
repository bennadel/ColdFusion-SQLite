<cfscript>

	// To create an in-memory SQLite database, you can use `jdbc:sqlite::memory:` as your
	// connection string. However, if you need to have multiple in-memory databases, you
	// can use the `file:` scheme and the `?mode=memory` query-string flag. In this case,
	// we're going to create two temporary, in-memory databases and trying writing to and
	// reading from each of them.
	// --
	// NOTE: I'm using a full directory path to a server directory, but this isn't
	// strictly necessary - the databases will be created in-memory no matter what path
	// you point to. However, if I change from "?mode=memory" to "?mode=rwc" (read, write,
	// create), then a physical database file will be created.
	temp1Datasource = {
		class: "org.sqlite.JDBC",
		connectionString: "jdbc:sqlite:file:/var/www-databases/temp-1.db?mode=memory",
		idleTimeout: 1 // In minutes.
	};
	temp2Datasource = {
		class: "org.sqlite.JDBC",
		connectionString: "jdbc:sqlite:file:/var/www-databases/temp-2.db?mode=memory",
		idleTimeout: 1 // In minutes.
	};

	// NOTE: The in-memory database will be dropped when the last connection to it is
	// closed. In this, with an `idleTimeout` of 1-minute, these databases will cease to
	// exist after a minute of no activity.

</cfscript>

<!--- Parameterize a table in each of the temporary, in-memory SQLite databases. --->
<cfquery datasource="#temp1Datasource#">
	CREATE TABLE IF NOT EXISTS `tokens` (
		`value` TEXT NOT NULL
	);
</cfquery>
<cfquery datasource="#temp2Datasource#">
	CREATE TABLE IF NOT EXISTS `tokens` (
		`value` TEXT NOT NULL
	);
</cfquery>

<!--- Insert a new token into each in-memory SQLite table. --->
<cfquery datasource="#temp1Datasource#">
	INSERT INTO tokens
		( value )
	VALUES
		( 'temp1-hello' ),
		( 'temp1-world' )
	;
</cfquery>
<cfquery datasource="#temp2Datasource#">
	INSERT INTO tokens
		( value )
	VALUES
		( 'temp2-foo' ),
		( 'temp2-bar' )
	;
</cfquery>

<!--- Query for values from each in-memory SQLite database. --->
<cfquery name="temp1Results" datasource="#temp1Datasource#">
	SELECT * FROM tokens ;
</cfquery>
<cfquery name="temp2Results" datasource="#temp2Datasource#">
	SELECT * FROM tokens ;
</cfquery>

<!--- Output the results side-by-side using CSS Flexbox. --->
<body style="display: flex ; gap: 20px ; align-items: flex-start ;">
	<cfdump
		label="SQLite: Temp-1 Database"
		var="#temp1Results#"
	/>
	<cfdump
		label="SQLite: Temp-2 Database"
		var="#temp2Results#"
	/>
</body>
