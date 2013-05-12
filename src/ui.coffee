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
	$('#username').val opt.uname if opt.uname?
	$('#num_symbol').val opt.nsym if opt.nsym?
	$('#length').val opt.len if opt.len?
	$('#generation').val opt.gen if opt.gen?
	$('#hashes').val opt.hashes if opt.hashes?
	return

save_options = (site, msg, show_note = true) ->
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
	util.storage.sync.set obj, msg, show_note

exports.save_default_options = ->
	save_options config.options_key, 'Password options'

exports.load_default_options = load_default_options = ->
	util.storage.sync.get config.options_key, (json) ->
		opt = config.options.default
		if json?
			console.log 'default options loaded'
			opt = JSON.parse json
		update_passwd_options opt
		console.log "default options #{JSON.stringify(opt)}"
		load_site_options() if $('#site').val()?

# Whether the site's password options has ever been saved.
site_option_saved = false

save_site_options = (show_note = true)->
	site = $('#site').val()
	save_options site, "Options for <b>#{site}</b>", show_note
	site_option_saved = true
	return

load_site_options = ->
	# make sure set_tabindex is called before return
	site = $('#site').val()
	if site == ''
		set_tabindex()
		return
	console.log "loading options for #{site}"
	util.storage.sync.get site, (json) ->
		if json?
			site_option_saved = true
			opt = JSON.parse(json)
			console.log "loaded options for #{site}: #{json}"
			update_passwd_options opt
			util.notify "Password option for <b>#{site}</b> loaded.", util.NOTIFY_KEEP
		set_tabindex()

##################################################
# Event handlers
##################################################

exports.gen_passwd = gen_passwd = (show_note = true) ->
	site = $('#site').val()
	if site  == '' || $('#salt').val() == '' || $('#passphrase').val() == ''
		$('#passwd').val ''
		return false
	input = gather_input()
	p = passwdgen.generate input
	$('#passwd').val p

	msg = "Password for <b>#{site}</b> generated. <br />"
	# If this site has never been saved, save it's options now.
	# This allows user to change default password options
	# without forgeting options for already used sites.
	if util.is_chromeext() && !site_option_saved
		save_site_options util.NO_NOTE
		msg += "Options also saved."
	util.notify msg if show_note
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

exports.site_update = ->
	site_option_saved = false
	delay_call gen_passwd

exports.delay_gen_passwd = delay_gen_passwd = ->
	delay_call gen_passwd
	return

exports.salt_update = ->
	localStorage.salt = $('#salt').val()
	delay_gen_passwd()
	return

exports.username_update = ->
	return if $('#site').val() == ''
	if util.is_chromeext()
		delay_call save_site_options
	return

exports.passwd_option_update = ->
	site = $('#site').val()
	return if site == ''
	passwd_generated = gen_passwd util.NO_NOTE
	msg = "Password for <b>#{site}</b> generated. <br />" if passwd_generated
	if util.is_chromeext()
		save_site_options util.NO_NOTE
		if passwd_generated
			msg += "Options also saved."
		else
			msg = "Options for <b>#{site}</b> saved."
	util.notify msg if msg != ''

exports.passwd_onclick = ->
	$(this).select()
	return

##################################################
# Initialization
##################################################

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
	set_one_tabindex id for id in [ 'salt', 'passphrase', 'site', 'passwd', 'username' ]
	return

exports.init = init = ->
	$('#salt').val localStorage.salt if localStorage.salt?
	if util.is_chromeext()
		console.log 'in chromeext'
		load_default_options()
	else
		# load_site_options will set tab index
		# this is awkward too because set_tabindex should be called after site options is updated
		set_tabindex()
	return
