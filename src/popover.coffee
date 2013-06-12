window.is_safariext = true

util = require './lib/util'
ui = require './ui'

clear_input = ->
	$('#passphrase').val ''
	$('#username').val ''
	$('#site').val ''
	$('#passwd').val ''

# Clear passphrase soon after popover is not showing.
validateHandler = (event) ->
	return unless event.target.identifier == "mypass"
	# console.log 'validate'
	if $('#passphrase').val() != ''
		clear_input()
	# remove listener to avoid calling again
	safari.application.removeEventListener("validate", validateHandler, true)

popoverHandler = (event) ->
	clear_input()
	tab = safari.application.activeBrowserWindow.activeTab
	# console.log "popover on #{tab.url}"
	if tab.url
		site = util.parse_site tab.url
		$('#site').val site
	ui.init()
	# TODO check validate event will not trigger when we focus in the popover
	safari.application.addEventListener("validate", validateHandler, true)

safari.application.addEventListener("popover", popoverHandler, true);

init = ->
	$('#site').on 'input', ui.site_update
	$('#site').on 'keypress', ui.site_keypress
	$('#salt').on 'input', ui.salt_update
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passphrase').on 'keypress', ui.passphrase_keypress
	$('#passwd').on 'click', ui.passwd_onclick
	# following are password options
	$('#username').on 'input', ui.username_update
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	$('#hashes').on 'change', ui.passwd_option_update
	return

$(document).on('DOMContentLoaded', init)
