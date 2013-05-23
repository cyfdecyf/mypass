exports.config =
	options_key: '##mypass_options##'
	salt_key: '##salt##'
	options:
		default:
			nsym: 0
			len: 16
			gen: 1
			hashes: 8
	pw:
		min_size: 8
		max_size: 20
