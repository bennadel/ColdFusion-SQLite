<cfscript>

	param name="url.userID" type="numeric" default="0";
	param name="form.action" type="string" default="";
	param name="form.taskID" type="string" default=0;
	param name="form.taskName" type="string" default="";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	users = new lib.MasterDAO()
		.getUsersByFilter( id = val( url.userID ) )
	;

	if ( ! users.len() ) {

		location(
			url = "./index.cfm",
			addToken = false
		);

	}

	user = users.first();
	userDAO = new lib.UserDAO( user.id );
	userDAO.ensureDatabase();

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	if ( form.action.len() ) {

		// CAUTION: I'm not doing any data massaging or validation here - I just want to
		// keep the code really simple so as to focus on the SQLite aspects.
		switch ( form.action ) {
			case "addTask":

				userDAO.addTask( form.taskName );

			break;
			case "deleteTask":

				userDAO.deleteTasksByFilter( id = val( form.taskID ) );

			break;
			case "toggleTask":

				task = userDAO
					.getTasksByFilter( id = val( form.taskID ) )
					.first()
				;
				userDAO.updateTask(
					id = task.id,
					isComplete = ! task.isComplete
				);

			break;
		}

		// BEST PRACTICE: Always refresh the page so that a CMD+R doesn't resubmit the
		// form and perform the same action twice.
		location(
			url = "./tasks.cfm?userID=#encodeForUrl( user.id )#",
			addToken = false
		);

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	tasks = userDAO.getTasksByFilter();

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
			#encodeForHtml( user.name )#
		</h1>

		<p>
			&larr; <a href="./index.cfm">Back to users</a>
		</p>

		<form method="post" action="./tasks.cfm?userID=#encodeForUrl( user.id )#">
			<input
				type="text"
				name="taskName"
				placeholder="Task..."
				value=""
				autofocus
				autocomplete="off"
				size="40"
				data-1p-ignore
			/>
			<button type="submit" name="action" value="addTask">
				Add Task
			</button>
		</form>

		<h2>
			Tasks
		</h2>

		<cfloop index="i" value="task" array="#tasks#">

			<form method="post" action="./tasks.cfm?userID=#encodeForUrl( user.id )#" class="item">
				<input
					type="hidden"
					name="taskID"
					value="#encodeForHtmlAttribute( task.id )#"
				/>
				<button
					type="submit"
					name="action"
					value="toggleTask">
					Toggle
				</button>
				<span data-completed="#yesNoFormat( task.isComplete )#">
					#dateFormat( task.createdAt, "yyyy-mm-dd" )#:
					#encodeForHtml( task.name )#
				</span>
				<button
					type="submit"
					name="action"
					value="deleteTask"
					class="push-right">
					Delete
				</button>
			</form>

		</cfloop>

		<cfif ! tasks.len()>
			<p>
				<em>No tasks.</em>
			</p>
		</cfif>

	</body>
	</html>

</cfoutput>
