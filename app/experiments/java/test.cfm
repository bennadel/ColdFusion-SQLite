
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
		<lite:queryparam value="token-#getTickCount()#" sqltype="varchar" />
	);
</lite:query>
<lite:query name="results" returnType="array" database="#database#">
	SELECT
		*
	FROM
		tokens
	;
</lite:query>

<cfdump var="#results#" />
