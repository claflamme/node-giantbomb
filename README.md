# Giant Bomb for Node.js

[![Travis](https://img.shields.io/travis/claflamme/node-giantbomb.svg)](https://travis-ci.org/claflamme/node-giantbomb)
[![npm](https://img.shields.io/npm/v/giantbomb.svg)](https://www.npmjs.com/package/giantbomb)

This **_entirely unofficial_** project is a JavaScript wrapper around the [Giant Bomb API](http://www.giantbomb.com/api/). It aims to provide a simple, consistent interface with robust documentation.

### Installation

```
npm install giantbomb
```

### Get Started

```js
const giantbomb = require('giantbomb');
const gb = giantbomb('API_KEY_HERE');

gb.games.get(16909, {}, (err, res, json) => {
  // Display details for Mass Effect.
  console.log(json.results);
});
```

### Documentation

Check out [the wiki](https://github.com/claflamme/node-giantbomb/wiki) for more information and examples.

### Support

If you have any problems or questions, please [create an issue](https://github.com/claflamme/node-giantbomb/issues) or message [hogonalog](http://www.giantbomb.com/profile/hogonalog/) on GiantBomb.
