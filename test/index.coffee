test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../dist/index'

test.createStream().pipe(tapSpec()).pipe process.stdout
gb = giantbomb process.env.API_KEY

test 'search - no config', (t) ->

  t.plan 2

  gb.search 'mass', {}, (err, res, body) ->
    t.equal body.error, 'OK', 'Returns OK.'
    t.true Array.isArray(body.results), 'Returns results.'

test 'search - specific resources', (t) ->

  t.plan 2

  config =
    resources: ['game', 'person']

  # Searching in specific resources.
  gb.search 'mass', config, (err, res, body) ->
    t.equal body.error, 'OK', 'Returns OK.'
    t.true Array.isArray(body.results), 'Returns results.'

test 'search - limiting results on multiple resources', (t) ->

  t.plan 1

  config =
    limit: 2

  testCall = ->
    gb.search 'mass', config

  t.throws testCall, 'Throws an exception.'

test 'game - no config', (t) ->

  t.plan 2

  gb.game 16909, {}, (err, res, body) ->
    t.equal body.error, 'OK', 'Returns OK.'
    t.ok body.results.id, 'Returns game details.'

test 'game - specific fields', (t) ->

  t.plan 3

  gb.game 16909, { fields: ['name'] }, (err, res, body) ->
    t.equal body.error, 'OK', 'Returns OK.'
    t.ok body.results.name, 'Contains requested field.'
    t.notOk body.results.id, 'ONLY contains requested field.'
