<cfscript>

	// As I'm experimenting with SQLite, I've been deleting the databases when I want to
	// change the table structures. This usually ends up causing a SQLite error:
	// 
	// > [SQLITE_READONLY_DBMOVED] The database file has been moved since it was opened
	// > (attempt to write a readonly database)
	// 
	// By restarting the ColdFusion application, it closes the datasource and allows the
	// new one to attach to the correct physical file.
	applicationStop();

	location(
		url = "./index.cfm",
		addToken = false
	);

</cfscript>
