api = require './api'
resources = require './resources'

buildResourceMethods = (api, resource) ->

  output = {}

  output.get = (resourceId, config, cb) ->
    api.sendDetailRequest "#{ resource.singular }/#{ resourceId }", config, cb

  output.list = (config, cb) ->
    if resource.sortBy and not config.sortBy
      config.sortBy = resource.sortBy
      config.sortDir = resource.sortDir
    api.sendListRequest resource.plural, config, cb

  if resource.searchBy
    output.search = (q, config, cb) ->
      config.filters or= []
      config.filters.push { field: resource.searchBy, value: q }
      output.list config, cb

  output

module.exports = (apiKey) ->

  api = api apiKey
  methods = {}

  for resourceName, resourceConfig of resources
    methods[resourceName] = buildResourceMethods api, resourceConfig

  # The search API is kind of fucked up compared to other list resources.
  # It takes different parameters and returns different results, so it has its
  # own special logic here.
  methods.search = (q, config, cb) ->

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

    api.sendRequest { url: 'search', qs: qs }, cb

  return methods
