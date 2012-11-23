
navigator.id.watch({
  loggedInUser: loggedInUser,
  onlogin: function(assertion) {
    var assertion_field, login_form;
    assertion_field = document.getElementById("assertion-field");
    assertion_field.value = assertion;
    login_form = document.getElementById("login-form");
    return login_form.submit();
  },
  onlogout: function() {}
});
