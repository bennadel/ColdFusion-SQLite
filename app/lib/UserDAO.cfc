component
	extends = "SQLiteDAO"
	hint = "I provide data access methods for a specific user database."
	{

	/**
	* I initialize the data access object (DAO) for the given user.
	*/
	public void function init( required numeric userID ) {

		// Each user gets their own, unique SQLite database.
		super.init( "user_#userID#.db" );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new task with the given name. The auto-generated ID is returned.
	*/
	public numeric function addTask( required string name ) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: userDAO.addTask(). */
			INSERT INTO task
			(
				name,
				isComplete,
				createdAt
			) VALUES (
				<cfqueryparam value="#name#" sqltype="varchar" />,
				FALSE,
				datetime( "now" )
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
	* I delete the tasks that match the given filters.
	*/
	public void function deleteTasksByFilter(
		numeric id,
		boolean isComplete
		) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: userDAO.deleteTasksByFilter(). */
			DELETE FROM
				task
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
			/* DEBUG: userDAO.ensureDatabase(). */
			CREATE TABLE IF NOT EXISTS `task` (
				`id` INTEGER PRIMARY KEY,
				`name` TEXT NOT NULL,
				`isComplete` INTEGER NOT NULL CHECK ( isComplete IN ( 0, 1 ) ),
				`createdAt` TEXT NOT NULL
			);
		</cfquery>
		```

	}

	/**
	* I get the tasks that match the given filters.
	*/
	public array function getTasksByFilter(
		numeric id,
		boolean isComplete
		) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#" returnType="array">
			/* DEBUG: userDAO.getTasksByFilter(). */
			SELECT
				t.id,
				t.name,
				t.isComplete,
				t.createdAt
			FROM
				task t
			WHERE
				TRUE

			<cfif arguments.keyExists( "id" )>
				AND
					t.id = <cfqueryparam value="#id#" sqltype="integer" />
			</cfif>

			<cfif arguments.keyExists( "isComplete" )>
				AND
					t.isComplete = <cfqueryparam value="#isComplete#" sqltype="integer" />
			</cfif>

			ORDER BY
				t.id ASC
			;
		</cfquery>
		```

		return results;

	}

	/**
	* I update the task with the given ID.
	*/
	public void function updateTask(
		required numeric id,
		boolean isComplete
		) {

		```
		<cfquery name="local.results" result="local.metaResults" datasource="#datasource#">
			/* DEBUG: userDAO.updateTask(). */
			UPDATE
				task
			SET
				<cfif arguments.keyExists( "isComplete" )>
					isComplete = <cfqueryparam value="#isComplete#" sqltype="integer" />,
				</cfif>

				id = id
			WHERE
				id = <cfqueryparam value="#id#" sqltype="integer" />
			;
		</cfquery>
		```

	}

}
