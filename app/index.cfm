<cfscript>

	param name="form.action" type="string" default="";
	param name="form.userID" type="numeric" default=0;
	param name="form.userName" type="string" default="";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// In the root page, we're going to use a master database to track the list of users.
	// Then, each user will receive their OWN DATABASE to record tasks.
	masterDAO = new lib.MasterDAO();
	masterDAO.ensureDatabase();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	if ( form.action.len() ) {

		// CAUTION: I'm not doing any data massaging or validation here - I just want to
		// keep the code really simple so as to focus on the SQLite aspects.
		switch ( form.action ) {
			case "addUser":

				masterDAO.addUser( form.userName );

			break;
			case "deleteUser":

				user = masterDAO
					.getUsersByFilter( id = val( form.userID ) )
					.first()
				;

				userDAO = new lib.UserDAO( user.id );
				userDAO.dropDatabase();
				masterDAO.deleteUsersByFilter( id = user.id );

			break;
		}

		// BEST PRACTICE: Always refresh the page so that a CMD+R doesn't resubmit the
		// form and perform the same action twice.
		location(
			url = "./index.cfm",
			addToken = false
		);

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	users = masterDAO.getUsersByFilter();

</cfscript>
<cfoutput>
	<!doctype html>
	<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<link rel="stylesheet" type="text/css" href="./public/main.css" />
	</head>
	<body>

		<h1>
			Lucee CFML SQLite Exploration
		</h1>

		<form method="post">
			<input
				type="text"
				name="userName"
				placeholder="Name..."
				value=""
				autofocus
				autocomplete="off"
				size="20"
				data-1p-ignore
			/>
			<button type="submit" name="action" value="addUser">
				Add User
			</button>
		</form>

		<h2>
			Users
		</h2>

		<cfloop index="i" value="user" array="#users#">

			<form method="post" class="item">
				<input
					type="hidden"
					name="userID"
					value="#encodeForHtmlAttribute( user.id )#"
				/>
				<a href="./tasks.cfm?userID=#encodeForUrl( user.id )#">
					#encodeForHtml( user.name )#
				</a>
				<button
					type="submit"
					name="action"
					value="deleteUser"
					class="push-right">
					Delete
				</button>
			</form>

		</cfloop>

		<cfif ! users.len()>
			<p>
				<em>No users.</em>
			</p>
		</cfif>

	</body>
	</html>

</cfoutput>
