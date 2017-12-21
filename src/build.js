({
    baseUrl: ".",
    paths: {
        underscore : 'components/underscore/underscore',
        jquery: 'components/jquery/dist/jquery.min',
        ansi_up: 'components/ansi_up/ansi_up',
        promise: 'components/es6-promise/es6-promise',
        codemirror: 'components/codemirror/',
        base: 'vendors/base',
        services: 'vendors/services',
        notebook: 'vendors/notebook',
		'codemirror/mode/meta': 'amalthea/codemirror/mode/meta',
		'codemirror/mode/r/r': 'amalthea/codemirror/mode/r',
		'codemirror/mode/xml/xml': 'amalthea/codemirror/mode/xml',
		'codemirror/mode/css/css': 'amalthea/codemirror/mode/css',
		'codemirror/mode/shell/shell': 'amalthea/codemirror/mode/shell',
		'codemirror/mode/julia/julia': 'amalthea/codemirror/mode/julia',
		'codemirror/mode/python/python': 'amalthea/codemirror/mode/python',
		'notebook/js/codemirror-ipython': 'amalthea/codemirror/mode/ipython',
		'codemirror/mode/htmlmixed/htmlmixed': 'amalthea/codemirror/mode/htmlmixed',
		'codemirror/mode/javascript/javascript': 'amalthea/codemirror/mode/javascript',
		'codemirror/addon/edit/matchbrackets': 'amalthea/codemirror/addon/matchbrackets',
		'codemirror/addon/edit/closebrackets': 'amalthea/codemirror/addon/closebrackets',
		'codemirror/addon/comment/comment': 'amalthea/codemirror/addon/comment',
		'codemirror/addon/runmode/runmode': 'amalthea/codemirror/addon/runmode'
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


