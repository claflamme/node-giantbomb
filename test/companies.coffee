module.exports = (test, gb) ->

  test 'companies.get - no config', (t) ->

    gb.companies.get 2215, {}, (err, res, json) ->
      t.ok json.results.id, 'Returns company details.'
      t.end()

  test 'companies.get - specific fields', (t) ->

    gb.companies.get 2215, { fields: ['name'] }, (err, res, json) ->
      t.ok json.results.name, 'Contains "name" field.'
      t.equal Object.keys(json.results).length, 1, 'Only contains "name" field.'
      t.end()

  test 'companies.list - no config', (t) ->

    gb.companies.list {}, (err, res, json) ->
      t.ok Array.isArray(json.results), 'Returns array of results.'
      t.equal json.results.length, 10, 'Default page length is 10.'
      t.equal json.offset, 0, 'Default offset is 0.'
      t.equal json.status_code, 1, 'Status code is 1.'
      t.end()

  test 'companies.list - specific fields', (t) ->

    config = fields: ['name', 'id']

    gb.companies.list config, (err, res, json) ->
      platform = json.results[0]
      t.equal Object.keys(platform).length, 2, 'Has only 2 fields.'
      t.ok platform.name, 'Has name.'
      t.ok platform.id, 'Has id.'
      t.end()
