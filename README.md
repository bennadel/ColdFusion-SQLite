
# ColdFusion SQLite Exploration

By [Ben Nadel][bennadel]

This is an exploration in using [**Lucee CFML**][lucee]&mdash;an open source ColdFusion application server&mdash;to connect to a series of **[SQLite][sqlite]** databases. It uses the [`sqllite-jdbc` driver from Xerial][sqlite-jdbc]. And, creates _temporary_ datasources as outlined in [the CommandBox book][commandbox-book].

To be clear, I have _no idea_ what I'm doing&mdash;none of the code in this repository should be considered a best practice. I'm just playing around with some new ideas.

## Creating In-Memory Databases

In my code, I'm writing physical `.db` files to disk. However, SQLite also allows for the use of in-memory databases that don't write to disk; and, which live for as long as the connection (I believe). You can use an in-memory database by prefixing the file-path with the `file:` scheme and adding the query-string flag, `?mode=memory`. For example:

``````cfm
<cfscript>

	datasource = {
		class: "org.sqlite.JDBC",
		connectionString: "jdbc:sqlite:file:/var/www-databases/master.db?mode=memory",
		idleTimeout: 5 // In minutes.
	};

	```
	<cfquery name="results" datasource="#datasource#">
		/* ... */
	</cfquery>
	```

</cfscript>
``````

Notice the connection string:

`jdbc:sqlite:file:/var/www-databases/master.db?mode=memory`

By prefixing the path with `file:`, it allows us to also use query-string parameters. And, in this case, the `?mode=memory` tells SQLite to treat `master.db` as an in-memory database. As such, `master.db` won't be written to disk. And, as a result, this also means that the `master.db` database will disappear after the connection times-out (which is 5-minutes in the above code).


[bennadel]: https://www.bennadel.com/

[commandbox-book]: https://commandbox.ortusbooks.com/usage/execution/cfml-files/using-a-db-in-cfml-scripts

[lucee]: https://www.lucee.org/

[sqlite]: https://www.sqlite.org/

[sqlite-jdbc]: https://github.com/xerial/sqlite-jdbc
