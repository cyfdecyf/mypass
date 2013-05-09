$ ->
	$('#site').on 'input', delay_gen_passwd
	$('#salt').on 'input', salt_update
	$('#passphrase').on 'input', delay_gen_passwd
	$('#passwd').on 'click', passwd_onclick
	$('#num_symbol').on 'change', passwd_option_update
	$('#length').on 'change', passwd_option_update
	$('#generation').on 'change', passwd_option_update
	$('#hashes').on 'change', passwd_option_update
	$('#dbg').on 'change', toggle_debug
	ui_init()
	return
