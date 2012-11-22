window.onload = function() {
	var signinLink = document.getElementById('signin');
	if (signinLink) {
		signinLink.onclick = function(e){
			navigator.id.request({
				siteName: 'Protobowl',
				oncancel: function() {
					alert('user refuses to share identity');
				}
			});
		};
	}

	var signoutLink = document.getElementById('signout');
	if (signoutLink) {
		signoutLink.onclick = function(e) {
			event.preventDefault();
			navigator.id.logout();
		};
	}
	 
	navigator.id.watch({
		loggedInUser: loggedInUser,
		onlogin: function(assertion) {
			console.log("doing this");
			var assertion_field = document.getElementById("assertion-field");
			assertion_field.value = assertion;
			var login_form = document.getElementById("login-form");
			login_form.submit();
		},
		onlogout: function () {
			window.location = '/logout';
		}
	});
};