$ ->
	$('#site').on 'input', delay_gen_passwd
	$('#username').on 'input', delay_gen_passwd
	$('#passphrase').on 'input', delay_gen_passwd
	$('#passwd').on 'click', passwd_onclick
	$('#num_symbol').on 'change', gen_passwd
	$('#length').on 'change', gen_passwd
	$('#generation').on 'change', gen_passwd
	$('#hashes').on 'change', delay_gen_passwd
	$('#dbg').on 'change', toggle_debug
	return
