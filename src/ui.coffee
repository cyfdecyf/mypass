{config} = require './lib/config'
util = require './lib/util'

PasswdGenerator = require('./lib/passwdgen').PasswdGenerator
passwdgen = new PasswdGenerator

gather_input = ->
	{
		salt: $('#salt').val()
		site: $('#site').val()
		passphrase: $('#passphrase').val()
		num_symbol: Number($('#num_symbol').val())
		length: Number($('#length').val())
		generation: Number($('#generation').val())
		itercnt: 1 << Number($('#hashes').val())
	}

##################################################
# Save/Load default and site password options
##################################################

# update password options on page
exports.update_passwd_options = update_passwd_options = (opt) ->
	if opt.uname?
		$('#username').val opt.uname
	else
		$('#username').val ''
	$('#num_symbol').val opt.nsym if opt.nsym?
	$('#length').val opt.len if opt.len?
	$('#generation').val opt.gen if opt.gen?
	$('#hashes').val opt.hashes if opt.hashes?
	return

save_options = (site, msg, show_note = true) ->
	return if site == ''
	opt =
		nsym: $('#num_symbol').val()
		len: $('#length').val()
		gen: $('#generation').val()
		hashes: $('#hashes').val()
	username = $('#username').val()
	if username? && username != ""
		opt.uname = username
	obj = {}
	obj[site] = JSON.stringify opt
	util.storage.set obj, msg, show_note

exports.save_default_options = ->
	save_options config.options_key, 'Password options'

exports.load_default_options = load_default_options = ->
	util.storage.get config.options_key, (json) ->
		opt = config.options.default
		if json?
			console.log 'default options loaded'
			opt = JSON.parse json
		update_passwd_options opt
		console.log "default options #{JSON.stringify(opt)}"
		load_site_options set_tabindex if $('#site').val()?

# Ugly hack. For gen_passwd to know whether options are loaded, saved, etc.
OPTION_STATE =
	NOT_FOUND: 1
	LOADED: 2
	SAVED: 3
	CHANGED: 4

site_option_state = OPTION_STATE.NOT_FOUND

save_site_options = (show_note = true)->
	site = $('#site').val()
	save_options site, "Options for <b>#{site}</b>", show_note
	site_option_state = OPTION_STATE.SAVED
	return

load_site_options = (cb = null) ->
	# make sure callback is called before return
	if is_standalone?
		cb() if cb?
		return
	site = $('#site').val()
	if site == ''
		cb() if cb?
		return
	if site_option_state == OPTION_STATE.LOADED ||
			site_option_state == OPTION_STATE.SAVED
		# no need to load
		cb() if cb?
		return
	console.log "loading options for #{site}"
	util.storage.get site, (json) ->
		if json?
			site_option_state = OPTION_STATE.LOADED
			opt = JSON.parse(json)
			console.log "loaded options for #{site}: #{json}"
			update_passwd_options opt
			if not_enough_input()
				util.notify "Option for <b>#{site}</b> loaded.", util.NOTIFY_KEEP
		else
			site_option_state = OPTION_STATE.NOT_FOUND
		cb() if cb?

##################################################
# Event handlers
##################################################

not_enough_input = ->
	$('#site').val()  == '' || $('#salt').val() == '' || $('#passphrase').val() == ''

# Save site options and generate password.
exports.gen_passwd = gen_passwd = (show_note = true) ->
	site = $('#site').val()

	opt_msg = ''
	options_saved = false
	# make sure we save password options even if password is not generated
	unless is_standalone? || site == ''
		if site_option_state == OPTION_STATE.LOADED
			opt_msg = "Using loaded options."
		else if site_option_state == OPTION_STATE.NOT_FOUND ||
				site_option_state == OPTION_STATE.CHANGED
			save_site_options util.NO_NOTE
			options_saved = true
			opt_msg += "Options also saved."

	if not_enough_input()
		$('#passwd').val ''
		util.notify "Options for <b>#{site}</b> saved." if options_saved
		return false

	input = gather_input()
	p = passwdgen.generate input
	$('#passwd').val p

	msg = "Password for <b>#{site}</b> generated. <br />"

	util.notify "#{msg} #{opt_msg}"  if show_note
	return true

lastInputTime = new Date(1970, 1, 1)
delayTime = 500

delay_call = (cb) ->
	triggerTime = lastInputTime = new Date().getTime()
	setTimeout(
		->
			if triggerTime == lastInputTime
				cb()
				return
		, delayTime)
	return

exports.site_update = site_update = ->
	site_option_state = OPTION_STATE.CHANGED

exports.site_keypress = (k) ->
	if k.which == 13
		console.log 'site input enter pressed'
		gen_passwd()

exports.delay_gen_passwd = delay_gen_passwd = ->
	delay_call gen_passwd
	return

exports.salt_update = ->
	# do not save anything for standalone page
	util.storage.set_salt $('#salt').val() unless is_standalone?
	delay_gen_passwd()
	return

exports.ios_salt_update = ->
	util.storage.set_salt $('#salt').val()

exports.username_update = ->
	return if $('#site').val() == '' || is_standalone?
	delay_call save_site_options
	return

exports.passwd_option_update = ->
	site = $('#site').val()
	return if site == ''
	site_option_state = OPTION_STATE.CHANGED
	gen_passwd()

exports.passwd_onclick = ->
	$(this).select()
	return

passphrase_plain_text = false

toggle_passphrase = ->
	console.log 'toggle_passphrase'
	pp = $('#passphrase')
	val = pp.val()
	tabindex = pp.prop 'tabindex'
	return if val == ''

	common = "class='input-block-level' " +
		"id='passphrase' placeholder='Press ENTER to toggle plain text' " +
		"value='#{val}' "
	common += "tabindex='#{tabindex}'"
	newpp =
		if passphrase_plain_text
			$("<input type='password' #{common}>")
		else
			$("<input type='text' #{common}>")

	# bind event handler
	newpp.on 'keypress', passphrase_keypress
	newpp.on 'input', delay_gen_passwd
	# do not auto select upon focus, also put cursor at the end
	newpp.on 'focus', -> @selectionStart = @selectionEnd = newpp.val().length
	pp.replaceWith newpp
	newpp.focus()

	passphrase_plain_text = !passphrase_plain_text

exports.passphrase_keypress = passphrase_keypress = (k) ->
	# console.log "passphrase key press #{k.which}"
	toggle_passphrase() if k.which == 13

##################################################
# Initialization
##################################################

set_site_typeahead = ->
	util.storage.load_all_sites (sites) ->
		# console.log "all sites #{sites}"
		$('#site').typeahead {
			source: sites
			updater: (item) ->
				console.log "#{item} selected"
				site_update()
				delay_call ->
					load_site_options gen_passwd
				item
		}
		return

set_tabindex = ->
	index = 1
	set_one_tabindex = (id) ->
		e = $('#'+id)
		if e.val() == ''
			# console.log "#{id} tabindex #{index} #{e.val()}"
			e.prop 'tabindex', index.toString()
			e.focus() if index == 1
			index++
			return
	set_one_tabindex id for id in [ 'salt', 'passphrase', 'site', 'passwd', 'username' ]
	return

exports.init = init = ->
	console.log 'ui init'

	# TODO the following code are for changing salt key without disturbing current user
	# remove the following 3 lines of code in the next version
	if localStorage.salt?
		util.storage.set_salt localStorage.salt
		delete localStorage.salt

	stored_salt = util.storage.get_salt()
	$('#salt').val stored_salt if stored_salt?
	if is_chromeext?
		console.log 'in chromeext'
		load_default_options()
	else
		# load_default_site_options will set tab index
		# this is awkward too because set_tabindex should be called after site options is updated
		set_tabindex()
	set_site_typeahead() unless is_standalone?
	return
