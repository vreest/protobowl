
navigator.id.watch({
	loggedInUser: loggedInUser,
	onlogin: (assertion) ->
		assertion_field = document.getElementById("assertion-field");
		assertion_field.value = assertion;
		login_form = document.getElementById("login-form");
		login_form.submit();

	onlogout: () ->
		
})
