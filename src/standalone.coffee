$ ->
	$('#site').on 'input', gen_passwd
	$('#num_symbol').on 'change', gen_passwd
	$('#length').on 'change', gen_passwd
	$('#generation').on 'change', gen_passwd
	$('#hashes').on 'change', gen_passwd
	$('#dbg').on 'change', toggle_debug
	return
