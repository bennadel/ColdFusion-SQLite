component
	extends = "SQLiteDAO"
	hint = "I provide data access methods for the master database (ie, the list of users)."
	{

	/**
	* I initialize the data access object (DAO) for the root experience.
	*/
	public void function init() {

		super.init( "master.db" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new user with the given name. The auto-generated ID is returned.
	*/
	public numeric function addUser( required string name ) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: masterDAO.addUser(). */
			INSERT INTO user
			(
				name
			) VALUES (
				<cfqueryparam value="#name#" sqltype="varchar" />
			)
			RETURNING
				ROWID
			;
		</cfquery>
		```

		// NOTE: SQLite doesn't return a "generatedKey". However, when a query ends with
		// "RETURNING ROWID", it will return a query with a single column, id, which
		// contains the generated value.
		return val( results.id );

	}

	/**
	* I delete the users that match the given filters.
	*/
	public void function deleteUsersByFilter(
		numeric id
		) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: masterDAO.deleteUsersByFilter(). */
			DELETE FROM
				user
			WHERE
				TRUE

			<cfif arguments.keyExists( "id" )>
				AND
					id = <cfqueryparam value="#id#" sqltype="integer" />
			</cfif>
			;
		</cfquery>
		```

	}

	/**
	* I ensure that the database tables exist.
	*/
	public void function ensureDatabase() {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: masterDAO.ensureDatabase(). */
			CREATE TABLE IF NOT EXISTS `user` (
				`id` INTEGER PRIMARY KEY,
				`name` TEXT NOT NULL
			);
		</cfquery>
		```

	}

	/**
	* I get the users that match the given filters.
	*/
	public array function getUsersByFilter(
		numeric id
		) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#" returnType="array">
			/* DEBUG: masterDAO.getUsersByFilter(). */
			SELECT
				u.id,
				u.name
			FROM
				user u
			WHERE
				TRUE

			<cfif arguments.keyExists( "id" )>
				AND
					u.id = <cfqueryparam value="#id#" sqltype="integer" />
			</cfif>

			ORDER BY
				u.id ASC
			;
		</cfquery>
		```

		return results;

	}

}
