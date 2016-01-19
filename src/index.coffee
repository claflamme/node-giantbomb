util = require 'util'
_ = require 'lodash'
request = require 'request'

formatFilterObject = (filter, i) ->

  # Normal filters only take a single value.
  # E.g. filter=name:assassin
  if filter.value
    return util.format '%s:%s', filter.field, filter.value

  # Date filters take a range.
  # E.g. filter=date_added:date1|date2
  if filter.start and filter.end
    start = filter.start.toISOString()
    end = filter.end.toISOString()
    return util.format '%s:%s|%s', filter.field, start, end

module.exports = (apiKey) ->

  httpDefaults =
    baseUrl: 'http://api.giantbomb.com/'
    json: true
    qs:
      api_key: apiKey
      format: 'json'
    qsStringifyOptions:
      encode: false

  _request: (opts, cb) ->

    opts = _.defaultsDeep opts, httpDefaults

    # A wee bit of debugging help.
    if process.env.NODE_DEBUG is 'giantbomb'
      url = opts.baseUrl + opts.url
      qs = require('qs').stringify opts.qs
      url = "#{ url }?#{ qs }"
      console.log '--> API Call: ' + url

    request opts, (err, res, body) ->

      if body.number_of_total_results
        total = body.number_of_total_results
        perPage = body.number_of_page_results
        body.number_of_total_pages = Math.ceil total / perPage

      cb err, res, body

  _buildListQuery: (config) ->

    qs =
      limit: config.perPage or 10
      offset: 0

    if config.fields
      qs.field_list = config.fields.join ','

    if config.page
      qs.offset = (config.page - 1) * qs.limit

    if config.sortBy
      qs.sort = config.sortBy + ':' + config.sortDir or 'asc'

    if config.filters
      filters = config.filters.map formatFilterObject
      qs.filter = filters.join ','

    return qs

  search: (q, config, cb) ->

    # The search API is kind of fucked up compared to other list resources.
    # It takes different parameters and returns different results, so it has its
    # own special logic here.

    if config.limit
      unless config.resources and config.resources.length is 1
        throw new Error 'Limit can only be set if searching a single resource.'

    qs =
      query: q
      limit: config.limit or 10
      page: config.page or 1

    if config.resources
      qs.resources = config.resources.join ','

    if config.fields
      qs.field_list = config.fields.join ','

    @_request { url: 'search', qs: qs }, cb

  game: (gameId, config, cb) ->

    qs = {}

    if config.fields
      qs.field_list = config.fields.join ','

    @_request { url: "game/#{ gameId }", qs: qs }, cb

  games: (config, cb) ->

    unless config.sortBy
      config.sortBy = 'number_of_user_reviews'
      config.sortDir = 'desc'

    qs = @_buildListQuery config

    @_request { url: 'games', qs: qs }, cb

  searchGames: (q, config, cb) ->

    config.filters = config.filters or []
    config.filters.push { field: 'name', value: q }

    @games config, cb
