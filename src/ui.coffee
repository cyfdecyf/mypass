passwdgen = null

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
		site: $('#site').val()
		generation: 0
		num_symbols: 3
		length: 12
	}

# TODO always use 1024 pass?
itercnt = ->
	1<<10

save_data = (email, derived_key) ->
	if is_chromeext()
		localStorage.email = email
		localStorage.derived_key = derived_key

clear_data = ->
	localStorage.email = null
	localStorage.derived_key = null

hide_emailpp = ->
	$('#email').val ''
	$('#pp').val ''
	$('#savekey').html 'Clear Derived Key'
	$('#emailpp').hide(200)
	return

show_emailpp = ->
	$('#emailpp').show(200)
	$('#savekey').html 'Save Derived Key'
	return

save_key = ->
	unless $('#emailpp').is ':visible'
		show_emailpp()
		clear_data()
		return
	email = $('#email').val()
	pp = $('#pp').val()
	if email == '' or pp == ''
		notify 'Both email and passphrase required.'
		return
	passwdgen = new window.PasswdGenerator(email, pp, itercnt(), null)
	save_data email, passwdgen.derived_key
	hide_emailpp()
	gen_passwd() # update generated password upon derived key change

	debug('derived key: ' + passwdgen.derived_key)

	return

gen_passwd = ->
	if $('#site').val() == ''
		$('#passwd').val ''
		return
	if passwdgen == null
		notify 'key not derived'
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
	if is_chromeext() && localStorage.derived_key?
		passwdgen = new window.PasswdGenerator(
			localStorage.email, null, null, localStorage.derived_key)
		hide_emailpp()

# export functions
window.toggle_debug = toggle_debug
window.save_key = save_key
window.gen_passwd = gen_passwd
window.parse_site = parse_site
window.ui_init = ui_init
