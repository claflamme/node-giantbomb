_ = require 'lodash'
request = require 'request'

SearchLimitError = (msg) ->
  @message = 'Limit can only be set if searching a single resource.'
  @name = 'SearchLimitError'
  return @

_sortByKey = (obj) ->

  keys = Object.keys(obj).sort()
  output = {}

  keys.forEach (key) ->
    output[key] = obj[key]

  return output

module.exports = (apiKey) ->

  httpDefaults =
    baseUrl: 'http://api.giantbomb.com/'
    json: true
    qs:
      api_key: apiKey
      format: 'json'

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

      cb err, res, _sortByKey body

  _buildListQuery: (config) ->

    qs =
      limit: config.perPage or 10
      offset: 0

    if config.fields
      qs.field_list = config.fields.join ','

    if config.page
      qs.offset = (config.page - 1) * qs.limit

    if config.sortBy
      qs.sort = config.sortBy + ':' + config.sortDirection or 'asc'

    if config.filters
      filters = config.filters.map (filter) ->
        filter.field + ':' + filter.value
      qs.filter = filters.join ','

    return qs

  search: (q, config, cb) ->

    # The search API is kind of fucked up compared to other list resources.
    # It takes different parameters and returns different results, so it has its
    # own special logic here.

    if config.limit
      unless config.resources and config.resources.length is 1
        throw SearchLimitError()

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
      config.sortDirection = 'desc'

    qs = @_buildListQuery config

    @_request { url: 'games', qs: qs }, cb

  searchGames: (q, config, cb) ->

    config.filters = config.filters or []
    config.filters.push { field: 'name', value: q }

    @games config, cb
