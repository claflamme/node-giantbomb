#### 2.0.1

2017-03-15

- Updated to use the new giantbomb.com/api URL.

2.0.0
-----

2017-03-15

- Removed the `videoTypes` resource. The video_type and video_types endpoints are now deprecated by giantbomb, and this package won't support them going forward.
- Added support for new video resources, with `get()` and `list()` methods for each (neither resource is searchable).
  - videoCategories
  - videoShows

1.0.0
-----

2017-01-06

- Refactored resource methods to make the config argument optional.

#### 0.4.1

2016-02-11

- Removed coffee-script as a dependency, compilation is now done in a prepublish script.

0.4.0
-----

2016-02-08

- Added support for the following resource types, with `get()` and `list()`. Most resources have `search()` methods, as well.
  - characters
  - concepts
  - franchises
  - gameRatings
  - genres
  - ratingBoards
  - people
  - locations
  - regions
  - themes
  - releases
  - accessories
  - objects
  - videos
  - videoTypes

0.3.0
-----

2016-02-05

- Added support for companies with `get()`, `list()`, and `search()` methods.
- Added support for reviews and user reviews, but only with `get()` and `list()` methods. The inability to filter on the `deck` or `description` fields makes searching kind of pointless.

0.2.0
-----

2016-02-03

- Added support for platforms, with `get()`, `list()`, and `search()` methods.

0.1.0
-----

2016-02-02

- Initial release with support for games.
