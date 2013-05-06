passwdgen = null
itercnt = 1<<8 # TODO make it user specifiable

notify = (msg) ->
	$('#content').append('<p>' + msg + '</p>')

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
	passwdgen = new window.PasswdGenerator(email, pp, itercnt)
	$('#email').val ''
	$('#pp').val ''
	$('#savekey').html 'Change Passphrase'
	$('#emailpp').hide(200)
	# notify 'Key derived.'

	s = CryptoJS.enc.Base64.stringify(passwdgen._key)
	notify "derived key: " + s

gen_passwd = ->
	if $('#site').val() == ''
		$('#passwd').val ''
		return
	if passwdgen == null
		notify 'key not derived'
		return
	# TODO make these use specifiable
	p = passwdgen.generate {
		site: $('#site').val()
		generation: 0
		num_symbols: 3
		length: 12
	}
	$('#passwd').val p
	return

# initialization
$ ->
	$('#savekey').on 'click', save_key
	$('#site').on 'input', gen_passwd
	return
