test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../index'

test.createStream().pipe(tapSpec()).pipe process.stdout
gb = giantbomb process.env.API_KEY

['search'].forEach (suite) ->
  require("./#{ suite }") test, gb

test 'games.get - no config', (t) ->

  gb.games.get 16909, {}, (err, res, body) ->
    t.ok body.results.id, 'Returns game details.'
    t.end()

test 'games.get - specific fields', (t) ->

  gb.games.get 16909, { fields: ['name'] }, (err, res, body) ->
    t.ok body.results.name, 'Contains requested field.'
    t.equal Object.keys(body.results).length, 1, 'Only contains one field.'
    t.end()

test 'games.list - no config', (t) ->

  gb.games.list {}, (err, res, body) ->
    t.ok Array.isArray(body.results), 'Returns array of results.'
    t.end()

test 'games.list - specific fields', (t) ->

  config =
    fields: ['name', 'id']

  gb.games.list config, (err, res, body) ->
    game = body.results[0]
    numKeys = Object.keys(game).length
    t.equal numKeys, 2, 'Has expected number of fields.'
    t.ok game.name, 'Has name.'
    t.ok game.id, 'Has id.'
    t.end()

test.only 'games.listById - no config', (t) ->

  gb.games.listById [16909, 21590], {}, (err, res, body) ->
    t.equal body.results.length, 2, 'Has 2 results.'
    t.end()
