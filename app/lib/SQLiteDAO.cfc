component
	output = false
	hint = "I provide the abstract base component for a SQLite data access layer."
	{

	/**
	* I initialize the data access object (DAO) with the given database file.
	*/
	package void function init( required string sqliteFilename ) {

		variables.sqliteFilename = arguments.sqliteFilename;
		// NOTE: We're using a per-application mapping to decouple the actual storage
		// location of the database files. That's why we're using expandPath() - so that
		// Lucee resolves to server's root path.
		variables.sqliteFilepath = expandPath( "/databases/#sqliteFilename#" );

		variables.datasource = {
			class: "org.sqlite.JDBC",
			connectionString: "jdbc:sqlite:#sqliteFilepath#"
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I determine if the physical SQLite database file exists.
	*/
	public boolean function databaseExists() {

		return fileExists( sqliteFilepath );

	}


	/**
	* I delete the file representing the current database.
	*/
	public void function dropDatabase() {

		if ( databaseExists() ) {

			fileDelete( sqliteFilepath );

		}

	}

}
