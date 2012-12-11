createAlert = (bundle, title, message) ->
	div = $("<div>").addClass("alert alert-success")
		.insertAfter(bundle.find(".annotations")).hide()
	div.append $("<button>")
		.attr("data-dismiss", "alert")
		.attr("type", "button")
		.html("&times;")
		.addClass("close")
	div.append $("<strong>").text(title)
	div.append " "
	div.append message
	div.slideDown()
	setTimeout ->
		div.slideUp().queue ->
			$(this).dequeue()
			$(this).remove()
	, 5000
	

userSpan = (user, global) ->
	prefix = ''
	text = ''

	if user.slice(0, 2) == "__"
		text = prefix + user.slice(2).replace(/_/g, ' ')
	else
		text = prefix + (room.users[user]?.name || "[name missing]")
	
	
	special = ''
	if user in room.admins
		special = 'admin'

	hash = 'userhash-' + special + '-' + escape(text).toLowerCase().replace(/[^a-z0-9]/g, '')
	
	if global
		scope = $(".user-#{user}:not(.#{hash})").attr('class', '')
	else
		scope = $('<span>')

	scope
		.addClass(hash)
		.addClass('user-'+user)
		.addClass('username')
		.text(text)

	if room.users[user]?._suffix
		scope.append ' '
		scope.append $('<span style="color: rgb(150, 150, 150)">').text(room.users[user]._suffix)
		
	

	if user.slice(0, 2) == "__"
		if /ninja/.test user
			scope.prepend "<i class='icon-magic user-prefix'></i>"	
		else
			scope.prepend "<i class='icon-bullhorn user-prefix'></i>"
	
	else if room.admins and user in room.admins
		scope.prepend "<i class='icon-star-empty user-prefix'></i>"	
	scope
		
addAnnotation = (el, name = sync?.name) ->
	# destroy the tooltip
	$('.bundle .ruling').tooltip('destroy')
	current_bundle = $('.room-' + (name || '').replace(/[^a-z0-9]/g, ''))
	if current_bundle.length is 0
		current_bundle = $('#history .bundle.active')
	current_block = current_bundle.eq(0).find('.annotations')
	if current_block.length is 0
		current_block = $('#history .annotations').eq(0)
	el.css('display', 'none').prependTo current_block
	el.slideDown()
	return el

addImportant = (el) ->
	$('.bundle .ruling').tooltip('destroy')
	if $('#history .bundle.active .sticky').length isnt 0
		el.css('display', 'none').prependTo $('#history .bundle.active .sticky')
	else
		el.css('display', 'none').prependTo $('#history .sticky:first')
	el.slideDown()
	return el


banButton = (id, line) ->
	return if id is me.id # stop hitting yourself

	usercount = (1 for i, u of room.users when u.active()).length
	is_admin = me.id[0] is '_' or me.id in room.admins
	
	if is_admin or (me.score() > 50 and usercount > 2)
		line.append $('<a>')
			.attr('href', '#')
			.attr('title', 'Initiate ban tribunal for this user')
			.attr('rel', 'tooltip')
			.addClass('label label-warning pull-right banhammer')
			.append($("<i>").addClass('icon-legal'))
			.click (e) ->
				e.preventDefault()
				me.trigger_tribunal id

	if is_admin
		line.append $('<a>')
			.attr('href', '#')
			.attr('title', 'Instantly ban this user for 10 minutes')
			.attr('rel', 'tooltip')
			.addClass('label label-important pull-right banhammer')
			.append($("<i>").addClass('icon-ban-circle'))
			.click (e) ->
				e.preventDefault()
				me.ban_user id
		

guessAnnotation = ({session, text, user, done, correct, interrupt, early, prompt}) ->
	# TODO: make this less like chats
	# console.log("guess annotat", text, done)
	# id = user + '-' + session
	id = "#{user}-#{session}-#{if prompt then 'prompt' else 'guess'}"
	# console.log id
	# console.log id
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id).addClass('guess')
		if prompt
			prompt_el = $('<a>').addClass('label prompt label-info').text('Prompt')
			line.append ' '
			line.append prompt_el
		else
			marker = $('<span>').addClass('label').text("Buzz")
			if early
				# do nothing, use default
			else if interrupt
				marker.addClass 'label-important'
			else
				marker.addClass 'label-info'
			line.append marker
		

		line.append " "
		line.append userSpan(user) #.addClass('author')
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line

		ruling = $('<a>')
			.addClass('label ruling')
			.hide()
			.attr('href', '#')
			.attr('title', 'Click to Report')
			.data('placement', 'right')
		line.append ' '
		line.append ruling
		# addAnnotation line
		annotation_spot = $('#history .bundle:first .annotations')
		if annotation_spot.length is 0
			annotation_spot = $('#history .annotations:first')
		line.css('display', 'none').prependTo annotation_spot
		line.slideDown()
	if done
		if text is ''
			line.find('.comment').html('<em>(blank)</em>')
		else
			line.find('.comment').text(text)
	else
		line.find('.comment').text(text)


	if done
		ruling = line.find('.ruling').show().css('display', 'inline')
		decision = ""
		if correct is "prompt"
			ruling.addClass('label-info').text('Prompt')
			decision = "prompt"
		else if correct
			decision = "correct"
			ruling.addClass('label-success').text('Correct')
			if user is me.id # if the person who got it right was me
				old_score = me.score()
				checkScoreUpdate = ->
					updated_score = me.score()
					if updated_score is old_score
						setTimeout checkScoreUpdate, 100
						return

					magic_multiple = 1000
					magic_number = Math.round(old_score / magic_multiple) * magic_multiple
					# console.log updated_score, old_score
					return if magic_number is 0 # 0 is hardly an accomplishment
					if magic_number > 0
						if old_score < magic_number and updated_score >= magic_number
							$('body').fireworks(magic_number / magic_multiple * 10)
							createAlert ruling.parents('.bundle'), 'Congratulations', "You have over #{magic_number} points! Here's some fireworks."
				checkScoreUpdate()
		else
			decision = "wrong"
			ruling.addClass('label-warning').text('Wrong')
			if user of room.users and room.users[user].score() < 0
				banButton user, line
			
			if user is me.id and me.id of room.users
				old_score = me.score()
				if old_score < -100 # just a little way of saying "you suck"
					createAlert ruling.parents('.bundle'), 'you suck', 'like seriously you really really suck. you are a turd.'


		answer = room.answer
		ruling.click ->
			me.report_answer {guess: text, answer: answer, ruling: decision}
			createAlert ruling.parents('.bundle'), 'Reported Answer', "You have successfully told me that my algorithm sucks. Thanks, I'll fix it eventually. "
			# I've been informed that this green box might make you feel bad and that I should change the wording so that it doesn't induce a throbbing pang of guilt in your gut. But the truth is that I really do appreciate flagging this stuff, it helps improve this product and with moar data, I can do science with it.

			# $('#review .review-judgement')
			# 	.after(ruling.clone().addClass('review-judgement'))
			# 	.remove()
				
			# $('#review .review-answer').text answer
			# $('#review .review-response').text text
			# $('#review').modal('show')
			return false

		if actionMode is 'guess'
			setActionMode ''
	# line.toggleClass 'typing', !done
	return line

chatAnnotation = ({session, text, user, done, time}) ->
	if !session
		session = 'auto-'+Math.random().toString(36).slice(3)
	id = user + '-' + session
	if $('#' + id).length > 0
		line = $('#' + id)
	else
		line = $('<p>').attr('id', id)
		line.append $('<span>').addClass('author').append(userSpan(user).attr('title', formatTime(time)))
		line.append document.createTextNode ' '
		$('<span>')
			.addClass('comment')
			.appendTo line
		addAnnotation line, room.users[user]?.room?.name

	url_regex = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig
	html = text.replace(/</g, '&lt;').replace(/>/g, '&gt;')
	.replace(/(^|\s+)(\/[a-z0-9\-]+)(\s+|$)/g, (all, pre, room, post) ->
		# console.log all, pre, room, post
		return pre + "<a href='#{room}'>#{room}</a>" + post
	).replace(url_regex, (url) ->
		real_url = url
		real_url = "http://#{url}" unless /:\//.test(url)
		if /\.(jpe?g|gif|png)$/i.test(url)
			# return ""
			return "<a href='#{real_url}' class='show_image' target='_blank'>#{url}</a> (click to show) 
				<div style='display:none;overflow:hidden' class='chat_image'>
					<img src='#{real_url}' alt='#{url}'>
				</div>"
		else
			return "<a href='#{real_url}' target='_blank'>#{url}</a>"
	).replace /!@([a-z0-9]+)/g, (match, user) ->
		return userSpan(user).addClass('recipient').clone().wrap('<div>').parent().html()
	
	if done
		line.removeClass('buffer')
		if text is '' or (text.slice(0, 1) is '@' and text.indexOf(me.id) == -1 and user isnt me.id)
			line.find('.comment').html('<em>(no message)</em>')
			line.slideUp()
		else
			if text.slice(0, 1) is '@'
				line.prepend '<i class="icon-user"></i> '
			line.find('.comment').html html

			if user of room.users and text.length > 70 or (dirty_regex? and dirty_regex.exec(" #{text} "))
				banButton user, line
	else
		if !$('.livechat')[0].checked or text is '(typing)'
			line.addClass('buffer')
			line.find('.comment').text(' is typing...')
		else
			line.removeClass('buffer')
			# line.find('.comment').text(text)

			line.find('.comment').html html

	line.toggleClass 'typing', !done


verbAnnotation = ({user, verb, time}) ->
	verbclass = "verb-#{user}-#{verb.split(' ').slice(0, 2).join('-')}"

	line = $('<p>').addClass 'log'
	line.addClass(verbclass)
	

	if user
		line.append userSpan(user).attr('title', formatTime(time))
		line.append " " + verb.replace /!@([a-z0-9]+)/g, (match, user) ->
			return userSpan(user).clone().wrap('<div>').parent().html()
	else
		line.append verb


	# if /paused the/.test(verb)
	if /paused the/.test(verb) or /skipped/.test(verb) or /category/.test(verb) or /difficulty/.test(verb) or /ban tribunal/.test(verb) or me.id[0] == '_'
		banButton user, line

	left = $(".bundle.active .verb-#{user}-left-the")
	if verb.split(' ')[0] is 'joined' and left.length > 0
		left.slideUp()
		verbAnnotation {user, verb: 'reloaded the page', time}
		return



	selection = $(".bundle.active .#{verbclass}")

	if selection.length > 0
		# For Thine is
		# Life is
		# For Thine is the

		# (3x) This is the way the world ends
		# Not with a bang but a whimper.


		line.data 'count', selection.data('count') + 1
		line.hide()
		line.prepend $('<span style="margin-right:5px">').addClass('badge').text(line.data('count') + 'x')
		selection.slideUp 'normal', ->
			$(this).remove()
		# line.slideDown 'normal'
		addAnnotation line
	else
		line.data 'count', 1
		addAnnotation line

logAnnotation = (text) ->
	line = $('<pre>')
	line.append text
	$("#history").prepend line.hide().slideDown()
	# addAnnotation line


notifyTrolls = ->
	addAnnotation($('<iframe width="420" height="315" src="http://www.youtube.com/embed/6bMLrA_0O5I?rel=0" frameborder="0" allowfullscreen></iframe>'))

# Ummmm ahh such as like, like the one where I'm like mmm and it says, 
# "I saw watchoo did there!" 
# And like and and then like you peoples were all like, 
# "YOU IS TROLLIN!" 
# and I was like 
# "I AM NOT TROLLING!! 
# I AM BOXXY YOU SEE! Mm!"

# (contemporary poetry)

boxxyAnnotation = ({id, tribunal}) ->
	{votes, time, witnesses, against} = tribunal
	return if me.id not in witnesses and me.id[0] != '_' # people who havent witnessed the crime do not constitute a jury of peers
	# majority + opposers - votes
	votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - votes.length + against.length

	line = $('<div>').addClass('alert').addClass('troll-' + id)
	if id is me.id # who would vote for their own banning?
		line.text('Protobowl has detected high rates of activity coming from your account.\n')
		line.append " <strong> Currently #{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes are needed to ban you from this room for 10 minutes)."
	else
		line.append $("<strong>").append('Is ').append(userSpan(id)).append(' trolling? ')
		line.append 'Protobowl has detected high rates of activity coming from the user '
		line.append userSpan(id)
		line.append '. If a majority of other active players vote to ban this user, the user will be sent to '
		line.append "<a href='/b'>/b</a> and banned from this room for 10 minutes. This message will be automatically dismissed in a minute. <br> "
		guilty = $('<button>').addClass('btn btn-small').text('Ban this user')
		line.append guilty
		line.append ' '
		not_guilty = $('<button>').addClass('btn btn-small').text("Don't ban")
		line.append not_guilty
		line.append " <strong> Currently #{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes are needed to ban "
		line.append userSpan(id)
		line.append ")"
		guilty.click ->
			me.vote_tribunal {user: id, position: 'ban'}
		not_guilty.click ->
			me.vote_tribunal {user: id, position: 'free'}
		
		guilty.add(not_guilty).disable((me.id in votes) or (me.id in against))
	
	if $('.troll-'+id).length > 0 and $('.troll-'+id).parents('.active').length > 0
		$('.troll-'+id).replaceWith line
	else
		$('.troll-'+id).slideUp 'normal', ->
			$(this).remove()
		if id isnt me.id or votes.length > 1
			addImportant line


congressionalAnnotation = ({id, elect}) ->
	

	line = $('<div>').addClass('alert alert-info').addClass('elect-' + id)

	if elect.term
		{witnesses, impeach} = elect
		votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - impeach.length

		if room.serverTime() > elect.term
			$('.elect-'+id).slideUp 'normal', ->
				$(this).remove()
			return
		if id is me.id
			line.html("You have access to the settings for <b>the next 60 seconds</b>. \n")
			finish = $('<button>').addClass('btn btn-small').text('Done')
			finish.click ->
				me.finish_term()
			line.append finish

		else
			# line.append $("<strong>").append('Impeach ').append(userSpan(id)).append('? ')
			# line.append "You have the option to impeach your elected officials. <br>"
			impeacher = $('<button>').addClass('btn btn-small').text("Impeach")
			impeacher.click ->
				me.vote_election {user: id, position: 'impeach'}
			
			line.append impeacher.disable(me.id in impeach)

			line.append " <strong> #{impeach.length} of #{witnesses.length-1} users have voted to impeach </strong>"
			line.append userSpan(id).css('font-weight', 'bold')
			line.append " (#{votes_needed} more votes needed)"

	else
		{votes, time, witnesses, against} = elect
		votes_needed = Math.floor((witnesses.length - 1)/2 + 1) - votes.length + against.length
		if id is me.id # who would vote for their own banning?
			line.html("You are a contestant in Protobowl's <i>Who Wants to be an Admin (for 60 seconds)</i>.\n")
			line.append " <strong>#{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes are needed to pass your referendum)"
		else
			line.append $("<strong>").append('Is ').append(userSpan(id)).append(' trustworthy? ')
			
			line.append "A user has requested power to change settings. Grant access if you believe the motives of "
			line.append userSpan(id)
			line.append " are pure. Elected terms are 1 minute. <br>"
			# line.append "will be granted one minute of control over the settings. You have one minute to cast your vote. <br> "
			worthy = $('<button>').addClass('btn btn-small').text('Grant access')
			line.append worthy
			line.append ' '
			not_worthy = $('<button>').addClass('btn btn-small').text("Deny")
			line.append not_worthy
			line.append " <strong> #{votes.length} of #{witnesses.length-1} users have voted</strong> (#{votes_needed} more votes needed)"
			worthy.click ->
				me.vote_election {user: id, position: 'elect'}
			not_worthy.click ->
				me.vote_election {user: id, position: 'deny'}
			
			worthy.add(not_worthy).disable((me.id in votes) or (me.id in against))
	
	if $('.elect-'+id).length > 0
		$('.elect-'+id).replaceWith line
	else
		addAnnotation line