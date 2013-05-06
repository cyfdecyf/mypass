passwdgen = null

notify = (msg) ->
	$('#info').html(msg).show().hide(3000)

debug_on = ->
	$('#dbg').is ':checked'

debug = (msg) ->
	if debug_on()
		$('#dbginfo').append('<p>' + msg + '</p>')

toggle_debug = ->
	$('#dbginfo').html ''

gather_input = ->
	# TODO make these user specifiable
	{
		site: $('#site').val()
		generation: 0
		num_symbols: 3
		length: 12
	}

# TODO always use 1024 pass?
itercnt = ->
	1<<10

save_key = ->
	unless $('#emailpp').is ':visible'
		$('#emailpp').show(200)
		$('#savekey').html 'Save Derived Key'
		return
	email = $('#email').val()
	pp = $('#pp').val()
	if email == '' or pp == ''
		notify 'Both email and passphrase required.'
		return
	passwdgen = new window.PasswdGenerator(email, pp, itercnt())
	$('#email').val ''
	$('#pp').val ''
	$('#savekey').html 'Change Passphrase'
	$('#emailpp').hide(200)
	notify 'Key derived.'

	if debug_on()
		debug "derived key: " + CryptoJS.enc.Base64.stringify(passwdgen._key)

	return

gen_passwd = ->
	if $('#site').val() == ''
		$('#passwd').val ''
		return
	if passwdgen == null
		notify 'key not derived'
		return
	p = passwdgen.generate gather_input()
	$('#passwd').val p
	return

# export functions
window.toggle_debug = toggle_debug
window.save_key = save_key
window.gen_passwd = gen_passwd
