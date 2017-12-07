# ![Amalthea](examples/icons/icon.svg) Amalthea

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![Build Status](https://travis-ci.org/Jinglue/Amalthea.svg?branch=master)](https://travis-ci.org/Jinglue/Amalthea)
[![npm](https://img.shields.io/npm/v/amalthea.svg)](https://www.npmjs.com/package/amalthea)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/amalthea_ai/Lobby)
[![Presented By Apollo Wayne](https://img.shields.io/badge/Presented%20By-Apollo%20Wayne-blue.svg)](https://twitter.com/shinerising)
[![shinerising's twitter](https://img.shields.io/twitter/follow/shinerising.svg?style=social&label=Follow)](https://twitter.com/shinerising)

![Amalthea Preview]()

## How to Use

You can load this plugin like normal JavaScript libraries:

```HTML
<script src="amalthea.js"></script>
<script type="text/javascript">
const amalthea = new Amalthea({
	//options
});
```

Alternatively, you can use SystemJS to load Amalthea dynamically:

```JavaScript
SystemJS.import('../dist/amalthea.js').then((root) => {
	const amalthea = new root.Amalthea({
		//options
	});
})
```