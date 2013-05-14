{print} = require 'util'
{spawn} = require 'child_process'

build = () ->
  os = require 'os'
  if os.platform() == 'win32'
    coffeeCmd = 'coffee.cmd'
  else
    coffeeCmd = 'coffee'
  coffee = spawn coffeeCmd, ['-c', '-o', 'build', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    if code != 0
      process.exit code

watch = () ->
    coffee = spawn 'coffee', ['-w', '-c', '-o', 'build', 'src']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()

task 'watch', 'Watch src/ for changes', ->
  watch()

task 'build', 'Build js/ from src/', ->
  build()

