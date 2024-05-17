<cfscript>

	param name="attributes.value" type="any";
	param name="attributes.sqltype" type="string";

	getBaseTagData( "cf_query" )
		.queryParams
		.append({
			value: attributes.value,
			type: attributes.sqltype.lcase().reReplace( "^cf_sql_", "" )
		})
	;

	// Insert positional parameter notation into SQL.
	echo( "?" );

	// There is no body or end mode functionality. Exit tag entirely.
	exit;

</cfscript>
