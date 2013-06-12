{config} = require './config'

host_is_ip = (host) ->
	parts = host.split '.'
	if parts.length != 4
		return false
	for pt in parts
		if pt.length == 0 || pt.length > 3
			return false
		n = Number(pt)
		if isNaN(n) || n < 0 || n > 255
			return false
	return true

top_level_dm =
	net: true
	org: true
	edu: true
	com: true
	ac: true
	co: true

parse_hostname = (url) ->
	a = document.createElement('a')
	a.href = url
	return a.hostname

host2domain = (host) ->
	if host_is_ip host
		return '' # IP address has no domain
	lastDot = host.lastIndexOf '.'
	if lastDot == -1
		return '' # simple host name has no domain

	parts = host.split '.'
	n = parts.length
	if n > 2 && top_level_dm[parts[n-2]]
		return parts[n-3..n-1].join '.'
	return parts[n-2..n-1].join '.'

exports.parse_site = parse_site = (url) ->
	if url.substr(0, 9) == 'chrome://'
		return ''
	if url.substr(0, 7) == 'file://'
		return ''
	host2domain(parse_hostname url)

#################################################
# Storage
#################################################

exports.SHOW_NOTE = true
exports.NO_NOTE = false

chrome_storage_set = (obj, msg, show_note = true) ->
	chrome.storage.sync.set(
		obj,
		->
			if chrome.runtime.lastError?
				notify "#{msg} save error: #{chrome.runtime.lastError}"
			else if msg != '' && show_note
				notify "#{msg} saved."
	)
	return

# assumes the key is a single string
chrome_storage_get = (key, cb) ->
	chrome.storage.sync.get(
		key,
		(items) ->
			if items? && items[key]?
				cb items[key]
				return
			cb null
			return
	)
	return

chrome_storage_del = (site) ->
	chrome.storage.sync.remove site, ->
		if chrome.runtime.lastError?
			alert "Error removing option for #{site}: #{chrome.runtime.lastError}"
			return
		console.log "Removed options for #{site}"

chrome_storage_load_all_sites = (cb) ->
	chrome.storage.sync.get null, (items) ->
		# Chrome only stores options_key in sync storage
		sites = (site for site, _ of items when site != config.options_key)
		cb sites

chrome_storage_load_all_site_options = (cb) ->
	chrome.storage.sync.get null, (items) ->
		cb items

local_storage_set = (obj, msg, show_note = true) ->
	for key, value of obj
		localStorage[key] = value
	if msg != '' && show_note
		notify "#{msg} saved."

local_storage_get = (key, cb) ->
	item = localStorage[key]
	if item?
		cb item
	else
		cb null

local_storage_del = (site) ->
	delete localStorage[site]
	console.log "Removed options for #{site}"

local_storage_load_all_sites = (cb) ->
	sites = (site for site, _ of localStorage when site != config.salt_key && site != config.options_key)
	cb sites

local_storage_load_all_site_options = (cb) ->
	cb localStorage

exports.storage =
	get_salt: ->
		localStorage[config.salt_key]
	set_salt: (salt) ->
		localStorage[config.salt_key] = salt

if is_chromeext?
	console.log 'setting storage to chrome.storage.sync'
	exports.storage.set = chrome_storage_set
	exports.storage.get = chrome_storage_get
	exports.storage.del = chrome_storage_del
	exports.storage.load_all_sites = chrome_storage_load_all_sites
	exports.storage.load_all_site_options = chrome_storage_load_all_site_options
else
	console.log 'setting storage to localStorage'
	exports.storage.set = local_storage_set
	exports.storage.get = local_storage_get
	exports.storage.del = local_storage_del
	exports.storage.load_all_sites = local_storage_load_all_sites
	exports.storage.load_all_site_options = local_storage_load_all_site_options

#################################################
# Notification
#################################################

exports.NOTIFY_KEEP = false

exports.notify = notify = (msg, hide = true) ->
	console.log msg
	info = $('#info')
	if info?
		info.html(msg).show()
		info.delay(1000).hide(300) if hide
