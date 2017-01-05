module.exports = (test, gb) ->

  test 'games.get()', (t) ->

    t.plan 2

    config = fields: ['id', 'name']

    gb.games.get 16909, config, (err, res, body) ->
      t.ok body.results.id, 'Returns details with config.'

    gb.games.get 16909, (err, res, body) ->
      t.ok body.results.id, 'Returns details with no config.'

  test 'games.list()', (t) ->

    t.plan 2

    config =
      page: 1
      fields: ['id', 'name']
      sortBy: 'original_release_date'
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
      t.true body.results.length > 0, 'Returns games with config'

    gb.games.list (err, res, body) ->
      t.true body.results.length > 0, 'Returns games with no config'

  test 'games.search()', (t) ->

    t.plan 2

    config = {
      filters: [
        {
          field: 'platforms'
          value: [96, 121]
        }
        {
          field: 'original_release_date'
          start: new Date('2010-06-01') # has no end date, will be dropped
        }
      ]
    }

    gb.games.search 'mass effect', config, (err, res, body) ->
      t.true body.results.length > 0, 'Returns games with config'

    gb.games.search 'mass effect', (err, res, body) ->
      t.true body.results.length > 0, 'Returns games with no config'
