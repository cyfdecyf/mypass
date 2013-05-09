purepack = require 'purepack'
C = if CryptoJS? then CryptoJS else null

config =
	pw: { min_size: 8, max_size: 16 }

# many code copied from derive.iced in 1SP
keymodes =
  WEB_PW : 0x1
  LOGIN_PW : 0x2
  RECORD_AES : 0x3
  RECORD_HMAC : 0x4

exports.PasswdGenerator = class PasswdGenerator
	# input should contain following property
	#     site, generation, num_symbol, length, salt, passphrase, itercnt
	generate: (input) ->
		dk = @derive_web_pw_key input.salt, input.passphrase, input.itercnt
		i = 0
		ret = null

		until ret
			a = [ "OneShallPass v2.0", input.salt, input.site, input.generation, i ]
			wa = pack_to_word_array a
			hash = C.HmacSHA512 wa, dk
			b64 = hash.toString C.enc.Base64
			ret = b64 if @is_ok_pw b64
			i++

		x = @add_syms ret, input.num_symbol
		x[0...input.length]

	derive_web_pw_key: (salt, passphrase, itercnt) ->
		# cache derived key for last salt, passphrase, itercnt tuple
		if @salt != salt || @passphrase != passphrase || @itercnt != itercnt
			@web_pw_key = @run_key_derivation salt, passphrase, itercnt, keymodes.WEB_PW
			@salt = salt
			@passphrase = passphrase
			@itercnt = itercnt
		return @web_pw_key

	run_key_derivation: (salt, passphrase, itercnt, key_mode) ->
		# The initial setup as per PBKDF2, with salt as the salt
		hmac = C.algo.HMAC.create C.algo.SHA512, passphrase
		block_index = C.lib.WordArray.create [ key_mode ]
		block = hmac.update(salt).finalize block_index
		hmac.reset()

		# Make a copy of the original block....
		intermediate = block.clone()

		i = 1
		while i < itercnt
			intermediate = hmac.finalize intermediate
			hmac.reset()
			block.words[j] ^= w for w,j in intermediate.words
			i++

		block

	# Rules for 'OK' passwords:
	#    - Within the first 8 characters:
	#       - At least one: uppercase, lowercase, and digit
	#       - No more than 5 of any one character class
	#       - No symbols
	#    - From characters 7 to 16:
	#       - No symbols
	is_ok_pw: (pw) ->
		caps = 0
		lowers = 0
		digits = 0

		for i in [0...config.pw.min_size]
			c = pw.charCodeAt i
			if @is_digit c then digits++
			else if @is_upper c then caps++
			else if @is_lower c then lowers++
			else return false

		bad = (x) -> (x is 0 or x > 5)
		return false if bad(digits) or bad(lowers) or bad(caps)

		for i in [config.pw.min_size...config.pw.max_size]
			return false unless @is_valid pw.charCodeAt i

		true

	# Given a PW, find which class to substitute for symbols.
	# The rules are:
	#    - Pick the class that has the most instances in the first
	#      8 characters.
	#    - Tie goes to lowercase first, and to digits second
	# Return a function that will say yes to the chosen type of character.
	find_class_to_sub: (pw) ->
		caps = 0
		lowers = 0
		digits = 0

		for i in [0...config.pw.min_size]
			c = pw.charCodeAt i
			if @is_digit c then digits++
			else if @is_upper c then caps++
			else if @is_lower c then lowers++

		if lowers >= caps and lowers >= digits then @is_lower
		else if digits > lowers and digits >= caps then @is_digit
		else @is_upper

	add_syms: (input, n) ->
		return input if n <= 0
		fn = @find_class_to_sub input
		indices = []
		for i in [0...config.pw.min_size]
			c = input.charCodeAt i
			if fn.call @, c
				indices.push i
				n--
				break if n is 0
		@add_syms_at_indices input, indices

	add_syms_at_indices: (input, indices) ->
		_map = "`~!@#$%^&*()-_+={}[]|;:,<>.?/";
		@translate_at_indices input, indices, _map

	translate_at_indices: (input, indices, _map) ->
		last = 0
		arr = []
		for index in indices
			arr.push input[last...index]
			c = input.charAt index
			i = C.enc.Base64._map.indexOf c
			c = _map.charAt(i % _map.length)
			arr.push c
			last = index + 1
		arr.push input[last...]
		arr.join ""

	is_upper: (c) -> "A".charCodeAt(0) <= c and c <= "Z".charCodeAt(0)
	is_lower: (c) -> "a".charCodeAt(0) <= c and c <= "z".charCodeAt(0)
	is_digit: (c) -> "0".charCodeAt(0) <= c and c <= "9".charCodeAt(0)
	is_valid: (c) -> @is_upper(c) or @is_lower(c) or @is_digit (c)

# copied from packed.iced in 1SP
# replace purepack with msgpack
pack_to_word_array = (obj) ->
	ui8a = purepack.pack(obj, 'ui8a')
	i32a = Ui8a.to_i32a ui8a
	v = (w for w in i32a)
	C.lib.WordArray.create v, ui8a.length

Ui8a =
	stringify : (wa) ->
		[v,n] = [wa.words, wa.sigBytes]
		out = new Uint8Array n
		(out[i] = ((v[i >>> 2] >>> (24 - (i % 4) * 8)) & 0xff) for i in [0...n])
		return out

	to_i32a : (uia) ->
		n = uia.length
		nw = (n >>> 2) + (if (n & 0x3) then 1 else 0)
		out = new Int32Array nw
		out[i] = 0 for i in [0...nw]
		for b, i in uia
			out[i >>> 2] |= (b << ((3 - (i & 0x3)) << 3))
		out
