util = require 'util'
request = require 'request'
_ = require 'lodash'

httpDefaults =
  baseUrl: 'http://api.giantbomb.com/'
  json: true
  headers:
    'User-Agent': 'Node.js client - npmjs.com/package/giantbomb'
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

buildDetailQuery = (config) ->

  qs = {}

  if config.fields
    qs.field_list = config.fields.join ','

  return qs

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

  sendRequest: (opts, cb) ->

    opts = _.defaultsDeep opts, httpDefaults
    opts.qs.api_key = apiKey

    # A wee bit of debugging help.
    request.debug = process.env.NODE_DEBUG is 'giantbomb'

    request opts, (err, res, body) ->

      if body.number_of_total_results
        total = body.number_of_total_results
        perPage = body.number_of_page_results
        body.number_of_total_pages = Math.ceil total / perPage

      cb err, res, body

  sendListRequest: (url, config, cb) ->

    @sendRequest { url: url, qs: buildListQuery config }, cb

  sendDetailRequest: (url, config, cb) ->

    @sendRequest { url: url, qs: buildDetailQuery config }, cb
