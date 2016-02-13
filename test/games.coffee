module.exports = (test, gb) ->

  test 'games.get()', (t) ->

    config = fields: ['id', 'name']

    gb.games.get 16909, config, (err, res, body) ->
      t.ok body.results.id, 'Returns game details.'
      t.end()

  test 'games.list()', (t) ->

    config =
      page: 1
      fields: ['id', 'name']
      filters: [
        {
          field: 'name'
          value: 'mass effect'
        }
        {
          field: 'original_release_date'
          start: new Date('2010-06-01')
          end: new Date()
        }
      ]

    gb.games.list config, (err, res, body) ->
      t.true body.results.length > 0, 'Returns games.'
      t.end()

  test 'games.search()', (t) ->

    gb.games.search 'mass effect', {}, (err, res, body) ->
      t.true body.results.length > 0, 'Returns games.'
      t.end()
