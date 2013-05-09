util = require './util'
ui = require './ui'

callOnActivePage = (callback) ->
	chrome.tabs.query({
		active: true,
		windowId: chrome.windows.WINDOW_ID_CURRENT
	},
	(tabs) ->
		callback(tabs[0])
		return
	)
	return

init = ->
	$('#site').on 'input', ui.delay_gen_passwd
	$('#salt').on 'input', ui.salt_update
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passwd').on 'click', ui.passwd_onclick
	$('#username').on 'input', ui.username_update
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	$('#hashes').on 'change', ui.passwd_option_update
	$('#dbg').on 'change', ui.toggle_debug
	# $("#info").val(window.location.search.substring(1))
	callOnActivePage((tab) ->
		# make sure when ui_init is called, site is already filled
		site = util.parse_site tab.url
		$('#site').val site
		ui.init()
		return
	)
	return

$(document).on('DOMContentLoaded', init)
