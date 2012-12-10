#= require ./lib/modernizr.js
#= require ./lib/bootstrap.js


navigator.id.watch {
	loggedInUser: window.logged_in_user,
	onlogin: (assertion) ->
		if me?
			$('#userinfo').fadeOut 'normal', ->
				wait_id(assertion)
		else
			$("form#browserid #assertion").val(assertion)
			$("form#browserid #return").val(location.pathname + location.search)
			$("form#browserid").submit()

	onlogout: ->
		if window.logged_in_user
			$('#userinfo').fadeOut()
			window.location = "/logout?return=#{encodeURIComponent(window.location.href)}"
		else
			$('#userinfo').fadeIn()
}

wait_id = (assertion) ->
	return setTimeout(wait_id, 137) if me.id.length isnt 40

	xhr = $.post "/auth/link", { assertion, id: me.id, room:room.name }

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


$('a[href="'+location.pathname+'"]').parent('li').addClass('active')