ui = require './ui'

$(document).ready ->
	ui.init()
	$('#salt').on 'input', ui.salt_update
	$('#genbtn').on 'click', ui.gen_passwd
	$('#passwd').on 'click', ui.passwd_onclick
	$('#num_symbol').on 'change', ui.passwd_option_update
	$('#length').on 'change', ui.passwd_option_update
	$('#generation').on 'change', ui.passwd_option_update
	$('#hashes').on 'change', ui.passwd_option_update
	return
