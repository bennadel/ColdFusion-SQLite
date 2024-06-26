<cfscript>

	if ( thistag.executionMode == "start" ) {

		param name="attributes.name" type="string" default="";
		param name="attributes.database" type="string";
		param name="attributes.returnType" type="string" default="query";

		queryParams = [];

		// Exit tag and allow the body of the tag to execute (and the queryParam child
		// tags to accumulate).
		exit
			method = "exitTemplate"
		;

	}

	// ASSERT: At this point, we've collected all of the query parameters and the SQL
	// statement (into the generatedContent) and we're ready to execute the SQL statement
	// against the datasource.

	// The body of the ColdFusion custom tag contains the SQL. Get a reference to it and
	// then reset the output so that we don't bleed the SQL into the page rendering.
	sql = thistag.generatedContent;
	thistag.generatedContent = "";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	sqlTypes = createObject( "java", "java.sql.Types" );

	// Define a Java datasource that points to the given SQLite file.
	datasource = createObject( "java", "org.sqlite.SQLiteDataSource" ).init();
	// NOTE: In order to use the in-memory database (`:memory:`) or any variation therein,
	// we'd have to create a connection pool that maintains a connection. Otherwise, the
	// in-memory database is dropped after ever SQL connection is closed.
	datasource.setUrl( "jdbc:sqlite:#attributes.database#" );

	try {

		// EXPERIMENTAL CONTEXT: In this version, we're creating a NEW CONNECTION to the
		// database every time the query is executed. This is sub-optimal. In a production
		// scenario, we'd want to create a CONNECTION POOL. But, that's more advanced than
		// I can do at this time.
		connection = datasource.getConnection();

		// Prepare the SQL statement with positional parameters. This allows us to use
		// dynamic, user-provided values while still preventing SQL injection attacks.
		statement = connection.prepareStatement( sql );
		applyQueryParams( statement, queryParams );

		// Execute the SQL statement against the database.
		// --
		// NOTE: Not all SQL queries return a ResultSet (ex. UPDATE and CREATE TABLE). As
		// such, we're using the .execute() method here followed, conditionally, by the
		// .getResultSet() method below.
		statement.execute();

		// If the NAME has been provided, we're going to assume the user knows what
		// they're doing, and that a ResultSet is expected (this is a poor assumption, but
		// is fine for the demo - the .getResultSet() can return NULL and we should check
		// for that in a more robust scenario).
		if ( attributes.name.len() ) {

			results = ( attributes.returnType == "query" )
				? convertResultSetToQuery( statement.getResultSet() )
				: convertResultSetToArray( statement.getResultSet() )
			;

			setVariable( "caller.#attributes.name#", results );

		}

	} finally {

		results?.close();
		statement?.close();
		connection?.close();

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I apply the query params as positional parameters to the given prepared statement.
	*/
	private void function applyQueryParams(
		required any statement,
		required array queryParams
		) {

		// I'm not exactly sure how every data-type maps to the proper method call. This
		// is below the surface that I usually operate on. ChatGPT helped me figure some
		// of this stuff out.
		// --
		// See: https://docs.oracle.com/en/java/javase/11/docs/api/java.sql/java/sql/PreparedStatement.html
		loop array="#queryParams#" index="local.i" value="local.queryParam" {

			switch ( queryParam.type ) {
				case "bit":
				case "boolean":
					statement.setBoolean( i, javaCast( "boolean", queryParam.value ) );
				break;
				case "integer":
					statement.setInt( i, javaCast( "int", queryParam.value ) );
				break;
				case "bigint":
					statement.setLong( i, javaCast( "long", queryParam.value ) );
				break;
				case "decimal":
				case "numeric":
					statement.setLong( i, javaCast( "bigdecimal", queryParam.value ) );
				break;
				case "double":
					statement.setDouble( i, javaCast( "double", queryParam.value ) );
				break;
				case "float":
				case "real":
					statement.setFloat( i, javaCast( "float", queryParam.value ) );
				break;
				case "smallint":
					statement.setShort( i, javaCast( "short", queryParam.value ) );
				break;
				case "tinyint":
					statement.setByte( i, javaCast( "byte", queryParam.value ) );
				break;
				case "date":
				case "timestamp":
					statement.setDate( i, dateAdd( "d", 0, queryParam.value ) );
				break;
				// case "time":
				// break;
				case "char":
				case "varchar":
				case "longvarchar":
					statement.setString( i, javaCast( "string", queryParam.value ) );
				break;
				// case "clob":
				// break;
				case "binary":
				case "varbinary":
				case "longvarbinary":
					statement.setBytes( i, queryParam.value );
				break;
				case "blob":
					statement.setBlob( i, queryParam.value );
				break;
				default:
					statement.setObject( i, queryParam.value );
				break;
			}

		}

	}


	/**
	* I convert the given SQL ResultSet into a ColdFusion array (of structs).
	*/
	private array function convertResultSetToArray( required any resultSet ) {

		var metadata = resultSet.getMetadata();
		var columnCount = metadata.getColumnCount();
		var rows = [];

		while ( resultSet.next() ) {

			var row = [:];

			for ( var i = 1 ; i <= columnCount ; i++ ) {

				// TODO: Is calling .getObject() sufficient for data-typing? When I dump-
				// out the results, they look properly cast. But, I'm not sure if that's
				// just something Lucee CFML is doing in the CFDump tag rendering. Also,
				// SQLite will store any data in any column; so, I am not sure if it's
				// even safe to assume that I can cast a column value consistently.
				row[ metadata.getColumnName( i ) ] = resultSet.getObject( i );

			}

			rows.append( row );

		}

		return rows;

	}


	/**
	* I convert the given SQL ResultSet into a ColdFusion query.
	*/
	private query function convertResultSetToQuery( required any resultSet ) {

		var metadata = resultSet.getMetadata();
		var columnCount = metadata.getColumnCount();
		var columnNames = [];
		var columnTypes = [];

		// Prepare the metadata for the ColdFusion query generation.
		for ( var i = 1 ; i <= columnCount ; i++ ) {

			columnNames.append( metadata.getColumnName( i ) );
			columnTypes.append( getQueryColumnType( metadata.getColumnType( i ) ) );

		}

		return queryNew(
			columnNames.toList(),
			columnTypes.toList(),
			convertResultSetToArray( resultSet )
		);

	}


	/**
	* I get the ColdFusion query column type from the given SQL type. This is used to
	* manually create ColdFusion queries with better column metadata.
	*/
	private string function getQueryColumnType( required numeric typeID ) {

		switch ( typeID ) {
			// Integer - 32-bit integer.
			case sqlTypes.INTEGER:
			case sqlTypes.SMALLINT:
			case sqlTypes.TINYINT:
				return "integer";
			break;
			// BigInt - 64-bit integer.
			case sqlTypes.BIGINT:
				return "bigint";
			break;
			// Double - 64-bit decimal number.
			case sqlTypes.DECIMAL:
			case sqlTypes.DOUBLE:
			case sqlTypes.FLOAT:
			case sqlTypes.NUMERIC:
			case sqlTypes.REAL:
				return "double";
			break;
			// Decimal - Variable length decimal, as specified by java.math.BigDecimal.
			// VarChar - String.
			case sqlTypes.CHAR:
			case sqlTypes.CLOB:
			case sqlTypes.LONGNVARCHAR:
			case sqlTypes.LONGVARCHAR:
			case sqlTypes.NCHAR:
			case sqlTypes.NCLOB:
			case sqlTypes.NVARCHAR:
			case sqlTypes.VARCHAR:
				return "varchar";
			break;
			// Binary - Byte array.
			// Bit - Boolean (1=True, 0=False).
			case sqlTypes.BIT:
			case sqlTypes.BOOLEAN:
				return "bit";
			break;
			// Time - Time.
			case sqlTypes.TIME:
			case sqlTypes.TIME_WITH_TIMEZONE:
				return "time";
			break;
			// Date - Date.
			case sqlTypes.DATE:
				return "date";
			break;
			// Timestamp - Time and date information.
			case sqlTypes.TIMESTAMP:
			case sqlTypes.TIMESTAMP_WITH_TIMEZONE:
				return "timestamp";
			break;
			case sqlTypes.ARRAY:
			case sqlTypes.BINARY:
			case sqlTypes.BLOB:
			case sqlTypes.DATALINK:
			case sqlTypes.DISTINCT:
			case sqlTypes.JAVA_OBJECT:
			case sqlTypes.LONGVARBINARY:
			case sqlTypes.NULL:
			case sqlTypes.OTHER:
			case sqlTypes.REF:
			case sqlTypes.REF_CURSOR:
			case sqlTypes.ROWID:
			case sqlTypes.SQLXML:
			case sqlTypes.STRUCT:
			case sqlTypes.VARBINARY:
			// Object - Java Object. This is the default column type.
			default:
				return "object";
			break;
		}

	}

</cfscript>
