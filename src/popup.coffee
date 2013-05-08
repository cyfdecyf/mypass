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

set_tabindex = ->
	index = 1
	if $('#username').val() == ''
		$('#username').prop('tabindex', index.toString())
		index++
	$('#passphrase').prop('tabindex', index.toString())
	index++
	$('#passwd').prop('tabindex', index.toString())

init = ->
	ui_init()
	set_tabindex()
	$('#site').on 'input', delay_gen_passwd
	$('#username').on 'input', username_update
	$('#passphrase').on 'input', delay_gen_passwd
	$('#passwd').on 'click', passwd_onclick
	$('#num_symbol').on 'change', gen_passwd
	$('#length').on 'change', gen_passwd
	$('#generation').on 'change', gen_passwd
	$('#hashes').on 'change', delay_gen_passwd
	$('#dbg').on 'change', toggle_debug
	# $("#info").val(window.location.search.substring(1))
	callOnActivePage((tab) ->
		$('#site').val(parse_site tab.url)
		return
	)
	return

$(document).on('DOMContentLoaded', init)
