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
	$("#info").val(window.location.search.substring(1))
	$('#siteinfo').addClass('hide')
	callOnActivePage((tab) ->
		$('#site').val(tab.url)
		return
	)
	return

$(document).on('DOMContentLoaded', init)
