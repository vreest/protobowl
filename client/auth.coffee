#= require modernizr.js
#= require bootstrap.js


navigator.id.watch {
	loggedInUser: window.logged_in_user,
	onlogin: (assertion) ->
		if me?
			$('#userinfo').fadeOut 'normal', ->
				wait_id(assertion)
		else
			$("form#browserid input").val(assertion)
			$("form#browserid").submit()

	onlogout: ->
		if window.logged_in_user
			$('#userinfo').fadeOut()
			window.location = '/logout'
		else
			$('#userinfo').fadeIn()
}

wait_id = (assertion) ->
	return setTimeout(wait_id, 137) if me.id.length isnt 40

	xhr = $.post "/auth/link", { assertion, id: me.id }

	xhr.success (data) ->
		$('#userinfo').fadeIn()
		json = JSON.parse(data)
		window.logged_in_user = json.email
		$("#signin").hide()
		$(".user-name").text json.username
		$("#user").show()
			
	xhr.error (data) ->
		$('#userinfo').fadeIn()
		logAnnotation data.responseText

$("a[href='/signin']").click (e) ->
	e.preventDefault()
	navigator.id.request()

$("a[href='/logout']").click (e) ->
	e.preventDefault()
	navigator.id.logout()

