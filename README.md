# ![Amalthea](https://jinglue.github.io/Amalthea/icons/icon.svg) Amalthea

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![Build Status](https://travis-ci.org/Jinglue/Amalthea.svg?branch=master)](https://travis-ci.org/Jinglue/Amalthea)
[![npm](https://img.shields.io/npm/v/amalthea.svg)](https://www.npmjs.com/package/amalthea)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/amalthea_ai/Lobby)
[![Presented By Apollo Wayne](https://img.shields.io/badge/Presented%20By-Apollo%20Wayne-blue.svg)](https://twitter.com/shinerising)
[![shinerising's twitter](https://img.shields.io/twitter/follow/shinerising.svg?style=social&label=Follow)](https://twitter.com/shinerising)

![Amalthea Preview](https://jinglue.github.io/Amalthea/images/preview.png)

## Attention

By now, Amalthea is still under development, thus we don't encourage you to use it in production. But you can have it builded and tested, and send us issues if you find any. We are now working with the document and user guide, you can keep watching this project to receive the latest information.

## What is Amalthea

Amalthea is a enhanced front-end version of Jupyter Notebook. With it, you can directly run your script within your browser, which could be beneficial for development document or online-education courses.

Check https://jinglue.github.io/Amalthea/ for demos

## Changelog

https://github.com/Jinglue/Amalthea/releases

## Download

Download Amalthea with NPM or Bower:

```shell
npm install amalthea --save
bower install amalthea --save
```

Then you can find the minified JavaScript Library in `dist` folder

## How to Use

Firstly, insert specific HTML elements to your webpage:

```HTML
<div data-amalthea-exercise data-lang="python3" data-executable>
  <pre>
    <code data-type="title">
      {{ TITLE }}
    </code>
  </pre>
  <pre>
    <code data-type="sample-code">
      {{ YOUR CODE }}
    </code>
  </pre>
</div>
```

then you can load this plugin like normal JavaScript libraries:

```HTML
<script src="amalthea.js"></script>
<script type="text/javascript">
const amalthea = new Amalthea({
  //options
});
</script>
```

Alternatively, you can use SystemJS to load Amalthea dynamically:

```JavaScript
SystemJS.import('../dist/amalthea.js').then((root) => {
  const amalthea = new root.Amalthea({
    //options
  });
})
```

Amalthea will render your webpage to enable online coding environment.