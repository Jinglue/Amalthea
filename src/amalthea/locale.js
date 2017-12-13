define([],
  function() {

    var en_text = {
      "STARTING": "Starting",
      "RUN": "Run",
      "RUNNING": "Working",
      "REPEAT": "Rerun",
      "NETINTER": "Disconnected",
      "BUSY": "Server Busy",
      "CONNERR": "Net Error",
      "RECONN": "Reworking",
      "RUNAGAIN": "Restart",
      "RUNTOTAL": "Run All",
      "ERRORINFO": "Oops, some errors occured. Perhaps you must run all your previous code.",
      "TITLE": "Exercise",
      "RESET": "RESET",
      "COPY": "COPY",
      "INTERRUPT": "Interrupt",
      "SHOWHINT": "Show Hint",
      "SHOWANS": "Show Answer",
      "HIDEHINT": "Hide Answer",
      "SUBMIT": "Submit",
      "SUCCESS": "Proceed!",
      "FAIL": "Decline!",
      "CSS": ".amalthea_wrap>.input:after{content:'INPUT'}.amalthea_pretext:after{content:'hidden pre-execution code exists'}.read-only .input:after{content:'PREVIEW'}.not-executable .input:after{content:none}.amalthea_output:after{content:'OUTPUT'}.amalthea_hint:after{content:'HINT'}.amalthea_solution:after{content:'SOLUTION'}"
    };
    var zh_text = {
      "STARTING": "启动中",
      "RUN": "运行",
      "RUNNING": "运行中",
      "REPEAT": "再次运行",
      "NETINTER": "连接中断",
      "BUSY": "服务器忙",
      "CONNERR": "连接失败",
      "RECONN": "重连中",
      "RUNAGAIN": "重新运行",
      "RUNTOTAL": "全部运行",
      "ERRORINFO": "看上去出现了一些错误，您可能需要运行之前的所有程序。",
      "TITLE": "测试题目",
      "RESET": "重置",
      "COPY": "复制",
      "INTERRUPT": "中断",
      "SHOWHINT": "显示提示",
      "SHOWANS": "显示答案",
      "HIDEANS": "隐藏答案",
      "SUBMIT": "提交答案",
      "SUCCESS": "答案通过！",
      "FAIL": "答案未通过！",
      "CSS": ".amalthea_wrap>.input:after{content:'输入'}.amalthea_pretext:after{content:'当前程序存在隐藏的预执行代码'}.read-only .input:after{content:'演示'}.not-executable .input:after{content:none}.amalthea_output:after{content:'输出'}.amalthea_hint:after{content:'提示'}.amalthea_solution:after{content:'答案'}"
    };
    var text;
    if (navigator && navigator.language !== undefined && navigator.language.startsWith('zh')) {
      text = zh_text;
    } else {
      text = en_text;
    }
    if (document) {
      var css = document.createElement("style");
      css.type = "text/css";
      css.innerHTML = text["CSS"];
      document.body.appendChild(css);
    }
    return text;
  })