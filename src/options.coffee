util = require './util'

exports.default_options = default_options =
	nsym: 0
	len: 12
	gen: 1
	hashes: 8

exports.options_key = options_key = '##mypass_options##'

exports.update_ui = update_ui = (opt) ->
	$('#username').val opt.uname if opt.uname?
	$('#num_symbol').val opt.nsym if opt.nsym?
	$('#length').val opt.len if opt.len?
	$('#generation').val opt.gen if opt.gen?
	$('#hashes').val opt.hashes if opt.hashes?
	return

# Store options in synced storage.
save_options = ->
	obj = {}
	obj[options_key] = JSON.stringify {
		nsym: $('#num_symbol').val()
		len: $('#length').val()
		hashes: $('#hashes').val()
	}
	util.storage.sync.set obj, 'Password options'

exports.load = load_options  = (cb = null) ->
	util.storage.sync.get options_key, (json) ->
		opt = default_options
		if json?
			console.log 'options loaded'
			opt = JSON.parse json
		update_ui opt
		console.log "options #{JSON.stringify(opt)}"
		cb() if cb?

$ ->
	return unless util.is_chromeext()
	# if called in popup page, no need to run the following
	return unless window.location.href.indexOf('popup.html') == -1
	$('#num_symbol').on 'change', save_options
	$('#length').on 'change', save_options
	$('#generation').on 'change', save_options
	$('#hashes').on 'change', save_options
	load_options()
	return
