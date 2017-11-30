({
    baseUrl: ".",
    paths: {
        underscore : 'components/underscore/underscore-min',
        jquery: 'components/jquery/dist/jquery.min',
		ansi_up: 'components/ansi_up/ansi_up',
		promise: 'components/es6-promise/es6-promise',
        codemirror: 'components/codemirror',
        base: 'vendors/base',
        services: 'vendors/services',
        notebook: 'vendors/notebook',
  },
  wrap: {
    "startFile": "wrap.start",
    "endFile": "wrap.end" 
  },
  shim: {
    underscore: {
      exports: '_'
    },
  },
    name: "main",
    out: "amalthea.js",
    optimize: 'uglify2'
})


