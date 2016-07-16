searchWithNoConfig = (t, gb) ->
  gb.search 'mass', {}, (err, res, body) ->
    t.true Array.isArray(body.results), 'Returns results with no config.'

searchWithFields = (t, gb) ->
  config = fields: ['id', 'name']
  gb.search 'mass', config, (err, res, body) ->
    t.true Array.isArray(body.results), 'Returns results with fields selected.'

searchWithFieldsAndResources = (t, gb) ->
  config =
    fields: ['id', 'name']
    resources: ['game', 'person']
  gb.search 'mass', config, (err, res, body) ->
    msg = 'Returns results with fields and resources selected.'
    t.true Array.isArray(body.results), msg

throwsWhenLimitingMultipleResources = (t, gb) ->
  testCall = ->
    gb.search 'mass', limit: 2
  t.throws testCall, 'Throws when limiting searches across multiple resources.'

module.exports = (test, gb) ->

  test 'search', (t) ->
    t.plan 4
    searchWithNoConfig t, gb
    searchWithFields t, gb
    searchWithFieldsAndResources t, gb
    throwsWhenLimitingMultipleResources t, gb
