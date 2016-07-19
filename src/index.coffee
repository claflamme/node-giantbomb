api = require './api'
resources = require './resources'

# ------------------------------------------------------------------------------
# Detail functions fetch a single item, by ID, from a resource. I use the word
# "detail" because they usually return more details about the resource than if
# it were returned as part of a list.
#
# You can access a resource's detail method via get(). Example:
#
#   gb.games.get(1234, {}, (err, res, json) => { ... });

buildDetailFunc = (api, resource) ->

  (resourceId, config, cb) ->
    resourcePath = "#{ resource.singular }/#{ resourceId }"
    api.sendDetailRequest resourcePath, config, cb

# ------------------------------------------------------------------------------
# List functions return a paginated collection of items from a resource. They
# support filtering and sorting, as well.
#
# List methods are accessible via list(). Example:
#
#   gb.platforms.list({}, (err, res, json) => { ... });

buildListFunc = (api, resource) ->

  (config, cb) ->
    if resource.sortBy and not config.sortBy
      config.sortBy = resource.sortBy
      config.sortDir = resource.sortDir
    api.sendListRequest resource.plural, config, cb

# ------------------------------------------------------------------------------
# Search functions are just for convenience. They're the same as list functions
# but with a filter pre-applied to the field by which you'd most likely want to
# search. They still accept all the same config options as a list function.
#
# Certain searchable resources will have a search() method. Example:
#
#   gb.companies.search('double fine', {}, (err, res, json) => { ... });

buildSearchFunc = (listFunc, resource) ->

  (q, config, cb) ->
    config.filters or= []
    config.filters.push { field: resource.searchBy, value: q }
    listFunc config, cb

# ------------------------------------------------------------------------------
# This function assigns the get() and list() methods for a given resource. If
# the resource has a `searchBy` property, a search() method is also assigned.

buildResourceMethods = (api, resource) ->

  output =
    get: buildDetailFunc api, resource
    list: buildListFunc api, resource

  if resource.searchBy
    output.search = buildSearchFunc output.list, resource

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
