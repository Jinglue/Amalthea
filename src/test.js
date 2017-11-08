var fs = require("fs");
function getFileSizeInKilobytes(filename) {
 var stats = fs.statSync(filename)
 var fileSizeInBytes = stats["size"]
 var fileSizeInKilobytes = fileSizeInBytes / 1000.0
 return fileSizeInKilobytes
}

var str=`/Users/Apollo/Documents/Projects/thebe-master/static/almond.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/namespace.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/jquery/jquery.min.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/es6-promise/promise.min.js
/Users/Apollo/Documents/Projects/thebe-master/static/amalthea/dotimeout.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/lib/codemirror.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/meta.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/utils.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/dialog.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/addon/edit/matchbrackets.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/addon/edit/closebrackets.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/addon/comment/comment.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/cell.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/underscore/underscore-min.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/keyboard.js
/Users/Apollo/Documents/Projects/thebe-master/static/services/config.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/security.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/outputarea.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/contexthint.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/completer.js
/Users/Apollo/Documents/Projects/thebe-master/static/base/js/events.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/celltoolbar.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/python/python.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/codemirror-ipython.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/codecell.js
/Users/Apollo/Documents/Projects/thebe-master/static/services/kernels/comm.js
/Users/Apollo/Documents/Projects/thebe-master/static/services/kernels/serialize.js
/Users/Apollo/Documents/Projects/thebe-master/static/services/kernels/kernel.js
/Users/Apollo/Documents/Projects/thebe-master/static/services/sessions/session.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/addon/runmode/runmode.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/tooltip.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/scrollmanager.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/notebook.js
/Users/Apollo/Documents/Projects/thebe-master/static/contents.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/actions.js
/Users/Apollo/Documents/Projects/thebe-master/static/notebook/js/kernelselector.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/r/r.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/julia/julia.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/xml/xml.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/javascript/javascript.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/css/css.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/htmlmixed/htmlmixed.js
/Users/Apollo/Documents/Projects/thebe-master/static/components/codemirror/mode/shell/shell.js
/Users/Apollo/Documents/Projects/thebe-master/static/main.js`;
var path = str.split('\n');
path.forEach(function(item){
	console.log(item.slice(32)+":"+getFileSizeInKilobytes(item)+"KB")
});