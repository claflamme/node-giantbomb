_ = require 'lodash'
request = require 'request'

SearchLimitError = (msg) ->
  @message = 'Limit can only be set if searching a single resource.'
  @name = 'SearchLimitError'
  return @

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

    request opts, cb

  search: (q, config, cb) ->

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
