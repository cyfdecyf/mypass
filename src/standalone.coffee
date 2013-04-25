@passwdgen

saveKey = ->
	email = $('#email').val()
	pp = $('#pp').val()
	@passwdgen = new window.PasswdGenerator(email, pp)
	s = CryptoJS.enc.Base64.stringify(@passwdgen._key)
	$('#info').html(s)
	$('#savekey').html('Change Passphrase')

# initialization
$ ->
	$('#savekey').on('click', saveKey)
	return
