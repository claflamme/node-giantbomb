module.exports = (test, gb) ->

  test 'platforms.get - no config', (t) ->

    gb.platforms.get 1, {}, (err, res, json) ->
      t.ok json.results.id, 'Returns platform details.'
      t.end()

  test 'platforms.get - specific fields', (t) ->

    gb.platforms.get 1, { fields: ['name'] }, (err, res, json) ->
      t.ok json.results.name, 'Contains "name" field.'
      t.equal Object.keys(json.results).length, 1, 'Only contains "name" field.'
      t.end()

  test 'platforms.list - no config', (t) ->

    gb.platforms.list {}, (err, res, json) ->
      t.ok Array.isArray(json.results), 'Returns array of results.'
      t.equal json.results.length, 10, 'Default page length is 10.'
      t.equal json.offset, 0, 'Default offset is 0.'
      t.equal json.status_code, 1, 'Status code is 1.'
      t.end()

  test 'platforms.list - specific fields', (t) ->

    config = fields: ['name', 'id']

    gb.games.list config, (err, res, json) ->
      platform = json.results[0]
      t.equal Object.keys(platform).length, 2, 'Has only 2 fields.'
      t.ok platform.name, 'Has name.'
      t.ok platform.id, 'Has id.'
      t.end()
