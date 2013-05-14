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
# Extension detection
#################################################

# make this global
exports.is_chromeext = is_chromeext = ->
	chrome? && chrome.storage?

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

exports.storage = {}

if is_chromeext()
	exports.storage.set = chrome_storage_set
	exports.storage.get = chrome_storage_get
else
	exports.storage.set = local_storage_set
	exports.storage.get = local_storage_get

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
