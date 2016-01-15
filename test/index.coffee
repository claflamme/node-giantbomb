test = require 'tape'
tapSpec = require 'tap-spec'
giantbomb = require '../dist/index'

test.createStream().pipe(tapSpec()).pipe process.stdout
gb = giantbomb process.env.API_KEY

test 'search: default', (t) ->

  t.plan 2

  gb.search 'mass', {}, (err, res, body) ->
    t.equal body.error, 'OK', 'Status is OK.'
    t.ok body.results, 'Contains results property.'

test 'search: limit, all resources', (t) ->

  t.plan 1

  testCall = ->
    gb.search 'mass', { limit: 2 }

  msg = 'Limit only allowed when searching a single-resource.'
  t.throws testCall, 'SearchLimitError', msg

test 'game: default', (t) ->

  t.plan 2

  gb.game 16909, {}, (err, res, body) ->
    t.equal body.error, 'OK', 'Status is OK.'
    t.ok body.results.id, 'Contains game details.'

test 'game: fields filter enabled', (t) ->

  t.plan 3

  gb.game 16909, { fields: ['name'] }, (err, res, body) ->
    t.equal body.error, 'OK', 'Status is OK.'
    t.ok body.results.name, 'Contains requested field.'
    t.notOk body.results.id, 'ONLY contains requested fields.'
