
<cfimport prefix="lite" taglib="./tags/" />

<cfset database = expandPath( "./test.db" ) />

<lite:query database="#database#">
	CREATE TABLE IF NOT EXISTS `tokens` (
		`id` INTEGER NOT NULL,
		`value` TEXT NOT NULL
	);
</lite:query>

<lite:query database="#database#">
	DELETE FROM
		tokens
	;
</lite:query>

<lite:query database="#database#">
	INSERT INTO tokens
	(
		id,
		value
	) VALUES (
		<lite:queryparam value="1" sqltype="integer" />,
		<lite:queryparam value="token-#createUniqueId()#" sqltype="varchar" />
	),(
		<lite:queryparam value="2" sqltype="integer" />,
		<lite:queryparam value="bleep" sqltype="varchar" />
	),(
		<lite:queryparam value="3" sqltype="integer" />,
		<lite:queryparam value="moop" sqltype="varchar" />
	),(
		<lite:queryparam value="4" sqltype="integer" />,
		<lite:queryparam value="kablamo" sqltype="varchar" />
	);
</lite:query>

<lite:query database="#database#">
	DELETE FROM
		tokens
	WHERE
		id = <lite:queryparam value="2" sqltype="integer" />
	;
</lite:query>

<!--- Get all tokens as a QUERY (default behavior). --->
<lite:query name="queryResults" database="#database#">
	SELECT
		*
	FROM
		tokens
	;
</lite:query>
<!--- Get all tokens as an ARRAY. --->
<lite:query name="arrayResults" returnType="array" database="#database#">
	SELECT
		*
	FROM
		tokens
	;
</lite:query>

<div style="display: flex ; gap: 20px ;">
	<cfdump
		label="ResultSet as Query"
		var="#queryResults#"
	/>
	<cfdump
		label="ResultSet as Array"
		var="#arrayResults#"
	/>
</div>
