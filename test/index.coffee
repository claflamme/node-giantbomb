test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../dist/index'

test.createStream().pipe(tapSpec()).pipe process.stdout
gb = giantbomb process.env.API_KEY

test 'search: default', (t) ->

  t.plan 2

  gb.search 'mass', {}, (err, res, body) ->
    t.equal body.error, 'OK', 'Response status is OK.'
    t.ok body.results, 'Response contains results property.'

test 'search: limit, multiple resources', (t) ->

  t.plan 1

  testCall = ->
    gb.search 'mass', { limit: 2 }

  msg = 'Limit only allowed when searching a single-resource.'
  t.throws testCall, 'SearchLimitError', msg
