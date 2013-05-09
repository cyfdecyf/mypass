passwdgen = new PasswdGenerator

chromeext = null

is_chromeext = ->
	if chromeext == null
		chromeext = $('#chromeext').length != 0
	chromeext

NOTIFY_HIDE = true
NOTIFY_NO_HIDE = false

SHOW_NOTE = true
NO_NOTE = false

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
		salt: $('#salt').val()
		site: $('#site').val()
		passphrase: $('#passphrase').val()
		username: $('#username').val()
		num_symbol: Number($('#num_symbol').val())
		length: Number($('#length').val())
		generation: Number($('#generation').val())
		itercnt: 1 << Number($('#hashes').val())
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

save_passwd_option = (show_note = SHOW_NOTE)->
	input = gather_input()
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
				notify "Options save error: #{chrome.runtime.lastError}"
			else if show_note
				notify "Options for <b>#{input.site}</b> saved."
	)
	return

gen_passwd = (show_note = SHOW_NOTE) ->
	if $('#site').val() == '' || $('#salt').val() == '' || $('#passphrase').val() == ''
		$('#passwd').val ''
		return
	input = gather_input()
	p = passwdgen.generate input
	$('#passwd').val p
	debug('derived key: ' + passwdgen.key)
	if is_chromeext() && show_note
		notify 'Password for <b>' + $('#site').val() + '</b> generated.'
	return

lastInputTime = new Date(1970, 1, 1)
delayTime = 300

delay_call = (cb) ->
	console.log 'delay call'
	triggerTime = lastInputTime = new Date().getTime()
	setTimeout(
		->
			if triggerTime == lastInputTime
				cb()
				return
		, delayTime)
	return

delay_gen_passwd = ->
	delay_call gen_passwd
	return

salt_update = ->
	if is_chromeext()
		localStorage.salt = $('#salt').val()
	delay_gen_passwd()
	return

username_update = ->
	if is_chromeext()
		delay_call save_passwd_option
	return

passwd_option_update = ->
	delay_call ->
		gen_passwd NO_NOTE
		save_passwd_option NO_NOTE if is_chromeext()
		msg = 'Password for <b>' + $('#site').val() + '</b> generated. <br />'
		msg += 'Options also saved.' if is_chromeext()
		notify msg

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

set_tabindex = ->
	index = 1
	set_one_tabindex = (id) ->
		e = $('#'+id)
		if e.val() == ''
			console.log "#{id} tabindex #{index} #{e.val()}"
			e.prop 'tabindex', index.toString()
			e.focus() if index == 1
			index++
			return
	set_one_tabindex id for id in [ 'site', 'salt', 'passphrase', 'passwd', 'username' ]
	return

ui_init = ->
	console.log 'ui_init'
	if is_chromeext()
		if localStorage.salt?
			$('#salt').val localStorage.salt
	site = $('#site').val()
	if site != ''
		get_passwd_option site, (opt) ->
			if opt?
				update_passwd_option opt
				notify "Password option for <b>#{site}</b> loaded.", NOTIFY_NO_HIDE
			set_tabindex()
	else
		set_tabindex()
	return

# export functions
window.toggle_debug = toggle_debug
window.username_update = username_update
window.salt_update = salt_update
window.passwd_option_update = passwd_option_update
window.passwd_onclick = passwd_onclick
window.gen_passwd = gen_passwd
window.delay_gen_passwd = delay_gen_passwd
window.parse_site = parse_site
window.ui_init = ui_init
