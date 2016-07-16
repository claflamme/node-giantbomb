module.exports = (api) ->

  get: (gameId, config, cb) ->

    api.sendDetailRequest "game/#{ gameId }", config, cb

  list: (config, cb) ->

    unless config.sortBy
      config.sortBy = 'number_of_user_reviews'
      config.sortDir = 'desc'

    api.sendListRequest 'games', config, cb

  search: (q, config, cb) ->

    config.filters or= []
    config.filters.push { field: 'name', value: q }

    @list config, cb
