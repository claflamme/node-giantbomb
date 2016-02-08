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

      qs = buildDetailQuery config

      sendRequest { url: "game/#{ gameId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'number_of_user_reviews'
        config.sortDir = 'desc'

      qs = buildListQuery config

      sendRequest { url: 'games', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  platforms:

    get: (platformId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "platform/#{ platformId }", qs: qs }, cb

    list: (config, cb) ->

      # There's currently a bug in sorting by install_base, but it should be
      # the default way to sort platforms (i.e. by popularity).

      # unless config.sortBy
      #   config.sortBy = 'install_base'
      #   config.sortDir = 'desc'

      qs = buildListQuery config

      sendRequest { url: 'platforms', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  companies:

    get: (companyId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "company/#{ companyId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'name'
        config.sortDir = 'asc'

      qs = buildListQuery config

      sendRequest { url: 'companies', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  reviews:

    get: (reviewId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "review/#{ reviewId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'publish_date'
        config.sortDir = 'desc'

      qs = buildListQuery config

      sendRequest { url: 'reviews', qs: qs }, cb

  userReviews:

    get: (reviewId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "user_review/#{ reviewId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'date_added'
        config.sortDir = 'desc'

      qs = buildListQuery config

      sendRequest { url: 'user_reviews', qs: qs }, cb

  gameRatings:

    get: (gameRatingId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "game_rating/#{ gameRatingId }", qs: qs }, cb

    list: (config, cb) ->

      unless config.sortBy
        config.sortBy = 'name'
        config.sortDir = 'asc'

      qs = buildListQuery config

      sendRequest { url: 'game_ratings', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  ratingBoards:

    get: (ratingBoardId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "rating_board/#{ ratingBoardId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'rating_boards', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  genres:

    get: (genreId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "genre/#{ genreId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'genres', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  franchises:

    get: (franchiseId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "franchise/#{ franchiseId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'franchises', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  characters:

    get: (characterId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "character/#{ characterId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'characters', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  concepts:

    get: (conceptId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "concept/#{ conceptId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'concepts', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb

  people:

    get: (personId, config, cb) ->

      qs = buildDetailQuery config

      sendRequest { url: "person/#{ personId }", qs: qs }, cb

    list: (config, cb) ->

      qs = buildListQuery config

      sendRequest { url: 'people', qs: qs }, cb

    search: (q, config, cb) ->

      config.filters or= []
      config.filters.push { field: 'name', value: q }

      @list config, cb
