class PasswdGenerator
	constructor: (email, passphrase) ->
		# TODO If localStorage has stored key, no need to generate again
		@_key = this.derive(email, passphrase)

	itercnt: 1 << 8

	derive: (email, passphrase) =>
		CryptoJS.PBKDF2 passphrase, email,
			{ keySize: 512/32, iterations: @itercnt, hasher: CryptoJS.algo.SHA512 }

window.PasswdGenerator = PasswdGenerator
