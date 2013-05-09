ui = require './ui'

$ ->
	$('#site').on 'input', ui.delay_gen_passwd
	$('#salt').on 'input', ui.salt_update
	$('#passphrase').on 'input', ui.delay_gen_passwd
	$('#passwd').on 'click', ui.passwd_onclick
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	$('#hashes').on 'change', ui.passwd_option_update
	$('#dbg').on 'change', ui.toggle_debug
	ui.init()
	return
