util = require 'util'
_ = require 'lodash'
request = require 'request'

httpDefaults =
  baseUrl: 'http://api.giantbomb.com/'
  json: true
  qs:
    api_key: ''
    format: 'json'
  qsStringifyOptions:
    encode: false

formatFilterObject = (filter, i) ->

  # Normal filters take a field name and value to query. It's sort of like
  # a WHERE clause.
  #
  #   E.g. return games where the name contains "assassin":
  #   &filter=name:assassin
  #
  # If filtering by the `id` field, you can pass in multple values. Values are
  # separated by pipes.
  #
  #   E.g. return results for Mass Effect 1 & 2:
  #   filter=id:16909|21590
  #
  # Keep in mind that the above doesn't return "detail" resources, so it's
  # suitable for displaying lists of items.
  if filter?.value?

    if not _.isArray filter.value
      filter.value = [filter.value]

    return util.format '%s:%s', filter.field, filter.value.join('|')

  # Date filters take a range.
  # E.g. filter=date_added:date1|date2
  if filter.start and filter.end
    start = filter.start.toISOString()
    end = filter.end.toISOString()
    return util.format '%s:%s|%s', filter.field, start, end

sendRequest = (opts, cb) ->

  opts = _.defaultsDeep opts, httpDefaults

  # A wee bit of debugging help.
  if process.env.NODE_DEBUG is 'giantbomb'
    request.debug = true

  request opts, (err, res, body) ->

    if body.number_of_total_results
      total = body.number_of_total_results
      perPage = body.number_of_page_results
      body.number_of_total_pages = Math.ceil total / perPage

    cb err, res, body

buildListQuery = (config) ->

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

module.exports = (apiKey) ->

  httpDefaults.qs.api_key = apiKey

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

    sendRequest { url: 'search', qs: qs }, cb

  games:

    get: (gameId, config, cb) ->

      qs = {}

      if config.fields
        qs.field_list = config.fields.join ','

      sendRequest { url: "game/#{ gameId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'number_of_user_reviews'
        config.sortDir = 'desc'

      qs = buildListQuery config

      sendRequest { url: 'games', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters = config.filters or []
      config.filters.push { field: 'name', value: q }

      @list config, cb
