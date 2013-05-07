C = if CryptoJS? then CryptoJS else null

config =
	pw: { min_size: 8, max_size: 16 }

class PasswdGenerator
	# input should contain following property
	#     site, generation, num_symbols, length, email, passphrase, itercnt
	generate: (input) ->
		dk = @derive_key(input.email, input.passphrase, input.itercnt)
		i = 0
		ret = null
		tmpl = [ "OneShallPass v2.0", input.email, input.site, input.generation ].join ""
		until ret
			# TODO 1SP uses purepack to concatenate strings, make it compatible with 1SP
			a = tmpl.concat i.toString()
			hash = C.HmacSHA512 a, dk
			b64 = hash.toString C.enc.Base64
			ret = b64 if @is_ok_pw b64
			i++
		x = @add_syms ret, input.num_symbols
		x[0...input.length]

	derive_key: (email, passphrase, itercnt) ->
		# TODO check if the derived key is the same as 1SP
		# what should be used as the key to HmacSHA512?

		# cache derived key for last email and passphrase pair
		if @email == email && @passphrase == passphrase
			return @key
		@key = C.PBKDF2 passphrase, email,
			{ keySize: 512/32, iterations: itercnt, hasher: C.algo.SHA512 }
		@email = email
		@passphrase = passphrase
		return @key

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

window.PasswdGenerator = PasswdGenerator
