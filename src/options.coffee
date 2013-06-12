if safari? && safari.extension?
	window.is_safariext = true
else if chrome? && chrome.storage?
	window.is_chromeext = true

# TODO site options loading does not work for Safari extension now.
#
# For Safari 6, the options page is neither global or popover page, so it does
# not have access to the safari.application and safari.extension. Thus:
#
# - Options page can't use safari settings directly
# - Options page has it's own local storage, but it want to read popover
#   page's local storage
#
# One solution to this problem is to let global page to manage storage and
# respond to message sent by ohter pages. But this is awkward. So I decided to
# wait Safari 7 and see if there will be new API to handle this.

{config} = require './lib/config'
ui = require './ui'
util = require './lib/util'

load_all_site_options = ->
	site_opt = $('#site-opt')
	# pass null to get all stored objects
	util.storage.load_all_site_options (items) ->
		for site, optjson of items
			continue if site == config.options_key || site == config.salt_key
			# console.log "#{site} #{optjson}"
			opt = JSON.parse optjson
			site_opt.append "<tr id='#{site}'>" +
				"<td>#{site}</td>" +
				"<td>#{opt.uname ? ''}</td>" +
				"<td>#{opt.nsym ? ''}</td>" +
				"<td>#{opt.len ? ''}</td>" +
				"<td>#{opt.gen ? ''}</td>" +
				"<td>#{opt.hashes ? ''}</td>" +
				"<td><button class='btn btn-mini' value='#{site}''>del</button></td>" +
				"</tr>"
		# must bind after button are created
		$('tbody#site-opt button').on 'click', remove_site_option
		return
	return

remove_site_option = ->
	site = @value
	btn = $("tbody#site-opt button[value='#{site}']")
	if btn.html() == 'del'
		btn.html 'ok?'
		return
	util.storage.del site
	# site may contain dot, so we can't use class#id as selector
	$("tbody#site-opt tr[id='#{site}']").remove()
	return

$ ->
	ui.load_default_options()
	load_all_site_options()
	$('#num_symbol').on 'change', ui.save_default_options
	$('#length').on 'change', ui.save_default_options
	$('#generation').on 'change', ui.save_default_options
	$('#hashes').on 'change', ui.save_default_options
	return
