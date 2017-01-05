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

  ->
    if arguments.length is 2
      [resourceId, cb] = arguments
      config = {}
    else
      [resourceId, config, cb] = arguments
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

  ->
    if arguments.length is 1
      [cb] = arguments
      config = {}
    else
      [config, cb] = arguments
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

  ->
    if arguments.length is 2
      [q, cb] = arguments
      config = {}
    else
      [q, config, cb] = arguments
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

# ------------------------------------------------------------------------------
# The search resource is actually a special endpoint that allows you to query
# more than one resource per request.
#
# If you search across multiple resources (e.g. games and platforms), it will
# concatenate the results from both resources into one list. This means accurate
# pagination isn't possible, since different resources may return a different
# number of results per page (it also means you can't filter or sort the
# results, since not all resources will have the same fields).

buildSearchResource = (api) ->

  (q, config, cb) ->

    qs =
      query: q
      limit: config.limit or 10
      page: config.page or 1

    if config.resources
      qs.resources = config.resources.join ','

    if config.fields
      qs.field_list = config.fields.join ','

    api.sendRequest { url: 'search', qs: qs }, cb

# ------------------------------------------------------------------------------
# This package provides an object with properties for each giantbomb resource
# (e.g. games, platforms, etc). Each property has methods for fetching data
# from that resource.

buildResources = (api, resources) ->

  methods =
    search: buildSearchResource api

  for name, resource of resources
    methods[name] = buildResourceMethods api, resource

  methods

module.exports = (apiKey) -> buildResources api(apiKey), resources
