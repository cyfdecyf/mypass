ui = require './ui'

$ ->
	$('#num_symbol').on 'change', ui.save_default_options
	$('#length').on 'change', ui.save_default_options
	$('#generation').on 'change', ui.save_default_options
	$('#hashes').on 'change', ui.save_default_options
	ui.load_default_options()
	return
