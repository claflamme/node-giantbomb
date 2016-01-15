module.exports = (test, gb) ->

  test 'search - no config', (t) ->

    gb.search 'mass', {}, (err, res, body) ->
      t.true Array.isArray(body.results), 'Returns results.'
      t.end()

  test 'search - specific resources', (t) ->

    config =
      resources: ['game', 'person']

    # Searching in specific resources.
    gb.search 'mass', config, (err, res, body) ->
      t.true Array.isArray(body.results), 'Returns results.'
      t.end()

  test 'search - limiting results on multiple resources', (t) ->

    t.plan 1

    config =
      limit: 2

    testCall = ->
      gb.search 'mass', config

    t.throws testCall, 'Throws an exception.'
