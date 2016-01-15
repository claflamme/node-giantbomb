test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../dist/index'

test.createStream().pipe(tapSpec()).pipe process.stdout
gb = giantbomb process.env.API_KEY

['search'].forEach (suite) ->
  require("./#{ suite }") test, gb

test 'game - no config', (t) ->

  gb.game 16909, {}, (err, res, body) ->
    t.ok body.results.id, 'Returns game details.'
    t.end()

test 'game - specific fields', (t) ->

  gb.game 16909, { fields: ['name'] }, (err, res, body) ->
    t.ok body.results.name, 'Contains requested field.'
    t.notOk body.results.id, 'ONLY contains requested field.'
    t.end()

test 'games - no config', (t) ->

  gb.games {}, (err, res, body) ->
    t.ok Array.isArray(body.results), 'array', 'Returns results.'
    t.end()

test 'games - specific fields', (t) ->

  config =
    fields: ['name', 'id']

  gb.games config, (err, res, body) ->
    game = body.results[0]
    numKeys = Object.keys(game).length
    t.equal body.error, 'OK', 'Returns OK.'
    t.equal numKeys, 2, 'Has expected number of fields.'
    t.ok game.name, 'Has name.'
    t.ok game.id, 'Has id.'
    t.end()
