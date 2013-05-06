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
	$('#savekey').on 'click', save_key
	$('#site').on 'input', gen_passwd
	$('#dbg').on 'change', toggle_debug
	ui_init()
	# $("#info").val(window.location.search.substring(1))
	callOnActivePage((tab) ->
		$('#site').val(tab.url)
		gen_passwd()
		return
	)
	return

$(document).on('DOMContentLoaded', init)
