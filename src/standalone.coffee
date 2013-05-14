ui = require './ui'

# Standalone page will not save password options, because it's designed for
# use when user can't access their own device.
window.standalone = true

$ ->
	ui.init()
	$('#site').on 'input', ui.delay_gen_passwd
	$('#salt').on 'input', ui.delay_gen_passwd
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passphrase').on 'keypress', ui.passphrase_keypress
	$('#passwd').on 'click', ui.passwd_onclick
	$('#num_symbol').on 'change', ui.gen_passwd
	$('#length').on 'change', ui.gen_passwd
	$('#generation').on 'change', ui.gen_passwd
	$('#hashes').on 'change', ui.gen_passwd
	return
