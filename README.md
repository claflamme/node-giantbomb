# Giant Bomb for Node.js

This **_entirely unofficial_** project is a JavaScript wrapper around the [Giant Bomb API](http://www.giantbomb.com/api/). It aims to provide a simple, consistent interface, and more robust documentation.

> **Heads up!!!** This package is immature, untested in production, and is being actively developed. Support for more resources will be added as time allows.

### Installation
This package is only available through npm. It does not support usage in browsers (you shouldn't be exposing your API key by making calls from the client side, anyways).

```
npm install giantbomb
```

### Get Started

Just require the installed `giantbomb` module. It exports a single function that creates a new instance of the API client.

```js
const giantbomb = require('giantbomb');
const gb = giantbomb('API_KEY_HERE');

gb.games.getById(16909, (err, res, json) => {
  // Display details for Mass Effect.
  console.log(json.results);
});
```

### Documentation

Check out [the wiki](https://github.com/claflamme/node-giantbomb/wiki) for more information on how to use the package.

### Support

If you have any problems or questions, please [create an issue](https://github.com/claflamme/node-giantbomb/issues) or message [hogonalog](http://www.giantbomb.com/profile/hogonalog/) on GiantBomb.







