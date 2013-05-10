options = require './options'
util = require './util'

PasswdGenerator = require('./passwdgen').PasswdGenerator
passwdgen = new PasswdGenerator

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

save_site_options = (show_note = true)->
	input = gather_input()
	optjson = JSON.stringify {
		uname: input.username
		nsym: input.num_symbol
		len: input.length
		gen: input.generation
	}
	obj = {}
	obj[input.site] = optjson
	util.storage.sync.set obj, "Options for <b>#{input.site}</b>", show_note
	return

load_site_options = ->
	site = $('#site').val()
	return if site == ''
	util.storage.sync.get site, (value) ->
		return unless value?
		options.update_ui JSON.parse(value)
		util.notify "Password option for <b>#{site}</b> loaded.", util.NOTIFY_NO_HIDE
		set_tabindex()

gen_passwd = (show_note = true) ->
	if $('#site').val() == '' || $('#salt').val() == '' || $('#passphrase').val() == ''
		$('#passwd').val ''
		return false
	input = gather_input()
	p = passwdgen.generate input
	$('#passwd').val p
	if show_note
		util.notify 'Password for <b>' + $('#site').val() + '</b> generated.'
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

exports.delay_gen_passwd = delay_gen_passwd = ->
	delay_call gen_passwd
	return

exports.salt_update = salt_update = ->
	localStorage.salt = $('#salt').val()
	delay_gen_passwd()
	return

exports.username_update = username_update = ->
	return if $('#site').val() == ''
	if util.is_chromeext()
		delay_call save_site_options
	return

exports.passwd_option_update = passwd_option_update = ->
	site = $('#site').val()
	return if site == ''
	delay_call ->
		passwd_generated = gen_passwd util.NO_NOTE
		msg = "Password for <b>#{site}</b> generated. <br />" if passwd_generated
		if util.is_chromeext()
			save_site_options util.NO_NOTE
			if msg?
				msg += "Options also saved."
			else
				msg = "Options for <b>#{site}</b> saved."
		util.notify msg if msg != ''

exports.passwd_onclick = passwd_onclick = ->
	$(this).select()
	return

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
	if util.is_chromeext()
		console.log 'in chromeext'
		$('#salt').val localStorage.salt if localStorage.salt?
		# this is awkward, inorder to make sure default option loaded before site options
		options.load load_site_options
	set_tabindex()
	return
