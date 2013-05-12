util = require './lib/util'
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
	callOnActivePage((tab) ->
		# make sure when ui_init is called, site is already filled
		site = util.parse_site tab.url
		$('#site').val site
		ui.init()
		return
	)
	$('#site').on 'input', ui.site_update
	$('#salt').on 'input', ui.salt_update
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passwd').on 'click', ui.passwd_onclick
	# following are password options
	$('#username').on 'input', ui.username_update
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	return

$(document).on('DOMContentLoaded', init)
