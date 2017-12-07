define([],
  function() {

    var en_text = {
      "STARTING": "Starting",
      "RUN": "Run",
      "RUNNING": "Working",
      "REPEAT": "Restart",
      "NETINTER": "Disconnected",
      "BUSY": "Server Busy",
      "CONNERR": "Net Error",
      "RECONN": "Reworking",
      "RUNAGAIN": "Run Again",
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
    };

    if (navigator && navigator.language !== undefined && navigator.language.startsWith('zh')) {
      return zh_text;
    }
    return en_text;
  })