passwdgen = new PasswdGenerator

chromeext = null

is_chromeext = ->
	if chromeext == null
		chromeext = $('#chromeext').length != 0
	chromeext

NOTIFY_HIDE = true
NOTIFY_NO_HIDE = false

notify = (msg, hide = NOTIFY_HIDE) ->
	info = $('#info').html(msg).show()
	if hide
		info.delay(1000).hide(300)

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
	{
		username: $('#username').val()
		passphrase: $('#passphrase').val()
		itercnt: 1 << Number($('#hashes').val())
		site: $('#site').val()
		generation: Number($('#generation').val())
		num_symbol: Number($('#num_symbol').val())
		length: Number($('#length').val())
	}

update_passwd_option = (opt) ->
	# Note saved opt key name and page element id mapping
	$('#username').val opt.uname
	$('#num_symbol').val opt.nsym
	$('#length').val opt.len
	$('#generation').val opt.gen
	return

get_passwd_option = (site, cb) ->
	chrome.storage.sync.get(
		site,
		(items) ->
			unless items?
				cb null
				return
			cb JSON.parse(items[site])
			return
	)
	return

save_passwd_option = (input) ->
	optjson = JSON.stringify {
		uname: input.username
		nsym: input.num_symbol
		len: input.length
		gen: input.generation
	}
	obj = {}
	obj[input.site] = optjson
	chrome.storage.sync.set(
		obj,
		->
			if chrome.runtime.lastError?
				notify "Password for <b>#{input.site}</b> generated. <br />" +
					"Options save error: #{chrome.runtime.lastError}"
			else
				notify "Password for <b>#{input.site}</b> generated. <br />" +
					"Options saved."
	)
	return

gen_passwd = ->
	if $('#site').val() == '' || $('#username').val() == '' || $('#passphrase').val() == ''
		$('#passwd').val ''
		return
	input = gather_input()
	p = passwdgen.generate input
	$('#passwd').val p
	debug('derived key: ' + passwdgen.key)
	if is_chromeext()
		save_passwd_option input
	else
		notify 'Password for <b>' + $('#site').val() + '</b> generated'
	return

lastInputTime = new Date(1970, 1, 1)
delayTime = 300

delay_gen_passwd = ->
	triggerTime = lastInputTime = new Date().getTime()
	setTimeout(
		->
			if triggerTime == lastInputTime
				gen_passwd()
				return
		, delayTime)
	return

username_update = ->
	if is_chromeext()
		localStorage.username = $('#username').val()
	delay_gen_passwd()
	return

passwd_onclick = ->
	$(this).select()
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
	host2domain(parse_hostname url)

ui_init = ->
	if is_chromeext() && localStorage.username? && localStorage.username != ''
		$('#username').val localStorage.username
	site = $('#site').val()
	if site != ''
		get_passwd_option site, (opt) ->
			return unless opt?
			update_passwd_option opt
			notify "Password option for <b>#{site}</b> loaded.", NOTIFY_NO_HIDE
	return

# export functions
window.toggle_debug = toggle_debug
window.username_update = username_update
window.passwd_onclick = passwd_onclick
window.gen_passwd = gen_passwd
window.delay_gen_passwd = delay_gen_passwd
window.parse_site = parse_site
window.ui_init = ui_init
