ui = require './ui'

$ ->
	ui.init()
	$('#site').on 'input', ui.delay_gen_passwd
	$('#salt').on 'input', ui.salt_update
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passphrase').on 'keypress', ui.passphrase_keypress
	$('#passwd').on 'click', ui.passwd_onclick
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	$('#hashes').on 'change', ui.passwd_option_update
	return
