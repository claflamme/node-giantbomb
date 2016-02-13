test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../dist/index'

unless process.env.API_KEY
  console.log '>> !!! You need to set an API_KEY environment variable !!! <<\n'
  process.exit()

test.createStream().pipe(tapSpec()).pipe process.stdout

gb = giantbomb process.env.API_KEY

[
  'search'
  'games'
].forEach (suite) ->
  require("./#{ suite }") test, gb
