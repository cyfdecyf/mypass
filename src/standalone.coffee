$ ->
	$('#savekey').on 'click', save_key
	$('#site').on 'input', gen_passwd
	$('#dbg').on 'change', toggle_debug
	return
