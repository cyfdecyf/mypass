passwdgen = new PasswdGenerator

chromeext = null

is_chromeext = ->
	if chromeext == null
		chromeext = $('#chromeext').length != 0
	chromeext

notify = (msg) ->
	$('#info').html(msg).show().hide(3000)

debug_on = ->
	$('#dbg').is ':checked'

debug = (msg) ->
	if debug_on()
		$('#dbginfo').append('<p>' + msg + '</p>')

verbose = (msg) ->
	$('#dbginfo').append('<p>' + msg + '</p>')

toggle_debug = ->
	$('#dbginfo').html ''

gather_input = ->
	# TODO collect password configuration from the page
	{
		email: $('#email').val()
		passphrase: $('#passphrase').val()
		itercnt: 1<<10
		site: $('#site').val()
		generation: 0
		num_symbols: 3
		length: 12
	}


save_data = () ->
	if is_chromeext()
		localStorage.email = $('#email').val()

hide_email = ->
	$('#saveemail').html 'Change Email'
	$('#email').hide(200)
	return

show_email = ->
	$('#email').show(200)
	$('#saveemail').html 'Save Email'
	return

save_email = ->
	if $('#email').is ':visible'
		# allow user to clear stored email
		save_data()
		email = $('#email').val()
		if email == ''
			notify 'email cleared'
		else
			hide_email()
	else
		show_email()
	return

gen_passwd = ->
	if $('#site').val() == ''
		$('#passwd').val ''
		return
	p = passwdgen.generate gather_input()
	$('#passwd').val p
	return

host_is_ip = (host) ->
	parts = host.split '.'
	if parts.length != 4
		return false
	for pt in parts
		if pt.length == 0 || pt.length > 3
			return false
		n = Number(pt)
		if isNaN(n) || n < 0 || n > 255
			return false
	return true

top_level_dm =
	net: true
	org: true
	edu: true
	com: true
	ac: true
	co: true

parse_hostname = (url) ->
	a = document.createElement('a')
	a.href = url
	return a.hostname

host2domain = (host) ->
	if host_is_ip host
		return '' # IP address has no domain
	lastDot = host.lastIndexOf '.'
	if lastDot == -1
		return '' # simple host name has no domain

	parts = host.split '.'
	n = parts.length
	if n > 2 && top_level_dm[parts[n-2]]
		return parts[n-3..n-1].join '.'
	return parts[n-2..n-1].join '.'

parse_site = (url) ->
	if url.substr(0, 9) == 'chrome://'
		return ''
	if url.substr(0, 7) == 'file://'
		return ''
	host = parse_hostname url
	host2domain host

ui_init = ->
	if is_chromeext() && localStorage.email? && localStorage.email != ''
		$('#email').val localStorage.email
		hide_email()

# export functions
window.toggle_debug = toggle_debug
window.save_email = save_email
window.gen_passwd = gen_passwd
window.parse_site = parse_site
window.ui_init = ui_init
