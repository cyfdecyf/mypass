{config} = require './lib/config'
ui = require './ui'
util = require './lib/util'

load_all_site_options = ->
	site_opt = $('#site-opt')
	# pass null to get all stored objects
	chrome.storage.sync.get null, (items) ->
		for site, optjson of items
			continue if site == config.options_key
			console.log "#{site} #{optjson}"
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
	chrome.storage.sync.remove site, ->
		if chrome.runtime.lastError?
			alert "Error removing option for #{site}: #{chrome.runtime.lastError}"
			return
		console.log "Remove options for #{site}"
		# site may contain dot, so we can't use class#id as selector
		$("tbody#site-opt tr[id='#{site}']").remove()
		return
	return

$ ->
	ui.load_default_options()
	load_all_site_options()
	$('#num_symbol').on 'change', ui.save_default_options
	$('#length').on 'change', ui.save_default_options
	$('#generation').on 'change', ui.save_default_options
	$('#hashes').on 'change', ui.save_default_options
	return
