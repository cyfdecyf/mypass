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
	if $('#email').val() == ''
		$('#email').prop('tabindex', index.toString())
		index++
	$('#passphrase').prop('tabindex', index.toString())
	index++
	$('#passwd').prop('tabindex', index.toString())

init = ->
	ui_init()
	set_tabindex()
	# focusout event may not occur, so use input event
	$('#email').on 'input', email_update
	$('#site').on 'input', gen_passwd
	$('#num_symbol').on 'change', gen_passwd
	$('#length').on 'change', gen_passwd
	$('#generation').on 'change', gen_passwd
	$('#hashes').on 'change', gen_passwd

	$('#dbg').on 'change', toggle_debug
	# $("#info").val(window.location.search.substring(1))
	callOnActivePage((tab) ->
		$('#site').val(parse_site tab.url)
		return
	)
	return

$(document).on('DOMContentLoaded', init)
