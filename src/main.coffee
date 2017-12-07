define [
  'base/js/namespace'
  'amalthea/locale'
  'jquery'
  'ansi_up'
  'promise'
  'vendors/dotimeout'
  'notebook/js/notebook'
  'vendors/contents'
  'base/js/events'
  'services/kernels/kernel'
  'codemirror/lib/codemirror'
  'codemirror/mode/python/python'
  'codemirror/mode/r/r'
  'codemirror/mode/julia/julia'
  'codemirror/mode/htmlmixed/htmlmixed'
  'codemirror/mode/css/css'
  'codemirror/mode/javascript/javascript'
  'codemirror/mode/shell/shell'

], (IPython, locale, $, ansi_up, promise, doTimeout, notebook, contents, events, kernel, CodeMirror) ->

  promise.polyfill()

  class Amalthea
    default_options:
      # jquery selector for elements we want to make runnable
      selector: 'div[data-executable]'
      # the url of either a tmnb server or a notebook server
      # (default url assumes user is running tmpnb via boot2docker)
      url: 'https://localhost:8080'
      # is the url for tmpnb or for a notebook
      tmpnb_mode: true
      # the kernel name to use, must exist on notebook server
      kernel_name: "python2"
      # set to false to prevent kernel_controls from being added
      append_kernel_controls_to: false
      # Default keyboard shortcut for focusing next cell, shift+ this keycode, default (32) is spacebar
      # Set to false to disable
      next_cell_shortcut: 32
      # Default keyboard shortcut for executing cell, shift+ this keycode, default (13) is return
      # Set to false to disable
      run_cell_shortcut: 13
      # For when you want a pre to become a CM instance, but not be runnable
      not_executable_selector: "div[data-not-executable]"
      # For when you want a pre to become a CM instance, but not be writable
      read_only_selector: "d1iv[data-read-only]"
      # if set to false, no addendum added, if a string, use that instead
      error_addendum: false
      # adds interrupt to every cell control, when it's running
      add_interrupt_button: false
      # hack to set the codemirror mode correctly
      codemirror_mode_name: "ipython"
      # hack to set the codemirror theme
      codemirror_theme_name: "default"
      # where are our cell elements (that are created from the selector option above)
      container_selector: "body"
      # for setting what docker image you want to run on the back end
      image_name: "jupyter/notebook"
      # show messages from @log()
      debug: false

    # some constants we need
    spawn_path: "api/spawn/"
    stats_path: "api/stats"
    # state constants
    start_state:     "start"
    idle_state:      "idle"
    busy_state:      "busy"
    ran_state:       "ran"
    full_state:      "full"
    cant_state:      "cant"
    disc_state:      "disconnected"
    gaveup_state:    "gaveup"
    user_error:      "user_error"
    interrupt_state: "interrupt"
    # I don't know an elegant way to use these pre instantiation
    ui: {}
    not_execute:     []
    typing:         []
    handler: {}
    options: {}
    
    setup_constants: ->
      @error_states     = [@disc_state, @full_state, @cant_state, @gaveup_state]
      @ui[@start_state] = locale['STARTING']
      @ui[@idle_state]  = locale['RUN']
      @ui[@busy_state]  = locale['RUNNING'] + '<svg version="1.1" class="amalthea-running" xmlns="http://www.w3.org/2000/svg" viewBox="-60 -60 98 42"><path class="cls-0" d="M0.2-32.9c19.4,0,36.3,7,45.1,17.4c-8.7-24.9-35.9-38-60.8-29.3C-29.3-40-40.1-29.2-44.9-15.5
  C-36.1-25.9-19.2-32.9,0.2-32.9"/><path class="cls-1" d="M42.2-52c0.1,4.9-3.7,8.9-8.5,9.1c-4.9,0.1-8.9-3.7-9.1-8.5c-0.1-4.8,3.6-8.8,8.4-9.1c4.9-0.2,9,3.5,9.2,8.4
  C42.2-52.1,42.2-52.1,42.2-52"/><path class="cls-2" d="M-41.1-37c-3.6,0.2-6.6-2.6-6.8-6.1s2.6-6.6,6.1-6.8c3.6-0.2,6.6,2.6,6.8,6.1c0,0,0,0,0,0v0.1
  C-34.8-40.2-37.6-37.2-41.1-37C-41.1-37-41.1-37-41.1-37L-41.1-37L-41.1-37z"/><path class="cls-3" d="M-2.2-65.3C-2-59-6.9-53.7-13.3-53.5s-11.6-4.7-11.8-11.1c-0.2-6.3,4.7-11.5,10.9-11.8
  c6.3-0.3,11.7,4.6,11.9,10.9C-2.2-65.4-2.2-65.3-2.2-65.3"/></svg>
'
      @ui[@ran_state]   = locale['REPEAT']
      # Button stays the same, but we add the addendum for a user error
      @ui[@user_error]  = locale['REPEAT']
      @ui[@interrupt_state]   = locale['NETINTER']
      @ui[@full_state]  = locale['BUSY']
      @ui[@cant_state]  = locale['CONNERR']
      @ui[@disc_state]  = locale['RECONN']
      @ui[@gaveup_state]= locale['RUNAGAIN']

      if @options.error_addendum is false then @ui['error_addendum']  = ""
      else if @options.error_addendum is true
        @ui['error_addendum']  = "<button data-action='run-above'>" + locale['RUNTOTAL'] + "</button> <div class='amalthea-message'>" + locale['ERRORINFO'] + "</div>"
      else @ui['error_addendum'] = @options.error_addendum

    # See default_options above
    constructor: (options={})->
      
      @options = options
      # important flags
      @has_kernel_connected = false
      @server_error = false

      # set options to defaults if they weren't specified
      # and break out some commonly used options
      {@selector, @url, @debug} = _.defaults(@options, @default_options)

      @setup_constants()

      # For dev/debug: because these values change a lot it's useful to be able to
      # override the values that are in the html file where amalthea is instantiated
      [qs_url, qs_tmpnb] = [@get_param_from_qs('url'), @get_param_from_qs('tmpnb_mode')]
      if qs_url              then @url = qs_url
      if qs_tmpnb is 'true'  then @options.tmpnb_mode = true
      if qs_tmpnb is 'false' then @options.tmpnb_mode = false

      # if we've been given a non blank url, make sure it has a trailing slash
      if @url then @url = @url.replace(/\/?$/, '/')
      # if we have a protocol relative url, add the current protocol
      if @url[0..1] is '//' then @url=window.location.protocol+@url

      if @options.tmpnb_mode
        @log 'Amalthea is in tmpnb mode'
        @tmpnb_url = @url
        # we will still need the actual url of our notebook server, so
        @url = ''

      # we break the notebook's method of tracking cells, so let's do it ourselves
      @cells = []
      # the jupyter global event object, jquery based, used for everything
      @events = events
      # click handlers
      @setup_user_events()
      
      @handler = @options.handler
      if @handler
        @handler.running = true
        @handler.node.addEventListener 'refresh', =>
          @build_amalthea(1)
        @handler.node.addEventListener 'add', =>
          @build_amalthea(2)
      
      # Start the notebook front end, creating cells with codemirror instances inside
      # and get everything set up for when the user hits run that first time
      @start_notebook()
      
      

    # NETWORKING
    # ----------------------
    #
    # CORS + redirects + are crazy, lots of things didn't work for this
    # this was from an example is on MDN
    call_spawn:(cell, cb)=>
      @log 'call spawn'
      @track 'call_spawn'
      # this should never happen
      if @kernel?.ws then @log 'HAZ WEBSOCKET?'
      invo = new XMLHttpRequest
      invo.open 'POST', @tmpnb_url+@spawn_path, true
      payload = JSON.stringify {image_name: @options.image_name}
      invo.onreadystatechange = (e)=>
        # if we're done, call the spawn handler
        if invo.readyState is 4 then  @spawn_handler(cell, e, cb)
      invo.onerror = (e)=>
        @log "Cannot connect to tmpnb server", true
        @set_state(@cant_state)
        @track 'call_spawn_fail'
      invo.send(payload)

    spawn_handler: (cell, e, cb) =>
      @log 'spawn handler called'
      # is the server up?
      if e.target.status in [0, 405]
        @log 'Cannot connect to tmpnb server, status: ' + e.target.status, true
        @set_state(@cant_state)
      else
        try
          data = JSON.parse e.target.responseText
        catch
          @log data
          @log "Couldn't parse spawn response"
          @track 'call_spawn_error'
        # is it full up of active containers?
        if data.status is 'full'
          @log 'tmpnb server full', true
          @set_state(@full_state)
          @track 'call_spawn_full'
        # otherwise start the kernel
        else
          # Check if URL is a full URL, adapt tmpnb_url as our new URL
          fullURL = data.url.match(/(https?:\/\/.[^\/]+)(.*)/i)
          if fullURL
            @tmpnb_url = fullURL[1]
            data.url = fullURL[2]

          # concat the base url with the one we just got
          @url = @tmpnb_url+data.url+'/'
          @log 'tmpnb says we should use'
          @log @url
          
          @start_kernel(cell, cb)
          
          @track 'call_spawn_success'


    # STARTUP & DOM MANIPULATION
    # ----------------------
    #
    build_amalthea: (action)=>
      # don't even try to save or autosave
      @notebook.writable = false

      # so that notebook.get_cells works, so widgets work
      @notebook.container = $(@options.container_selector)
      
      if action is 1
        @cells = []
        n = @notebook.ncells()
        i = 0
        while i < n
          @notebook._unsafe_delete_cell(i)
          i += 1
          
      i0 = @cells.length
      $(@selector).add(@options.not_executable_selector).each (i, el) =>
        i += i0
        lang = $(el).data('lang')
        if lang is 'single' or lang is 'multiple' or lang is 'blank'
          
          cell = @notebook.insert_cell_at_bottom('code')
          title = $(el).find('div[data-type="title"]').text().trim()
          if not title
            title = locale['TITLE']
          cell.set_title title
          cell.set_solution $(el).find('div[data-type="solution"]').html()
          cell.set_hint $(el).find('div[data-type="hint"]').html()
          cell.set_lang lang
          langStr = cell.get_lang();
        
          input = $("<div class='amalthea_quiz' data-cell-id='#{i}'></div>")
          
          if lang is 'single'
            sct = [0,0,0,0]
            arr = [0,1,2,3]
            @shuffle(arr)
            input.append "<div class='amalthea_quiz_info'>"+$(el).find('div[data-type="info"]').html()+"</div>"
              
            arr.forEach (num, idx) =>
              item = $(el).find('div[data-type="option"]').eq(num)
              if item.data('correct')
                sct[idx] = 1
              input.append "<div class='amalthea_quiz_option' data-action='select'><span class='radio'></span><span>"+item.html()+"</span></div>"
            cell.set_sct sct
          else if lang is 'multiple'
            sct = [0,0,0,0]
            arr = [0,1,2,3]
            @shuffle(arr)
            input.append "<div class='amalthea_quiz_info'>"+$(el).find('div[data-type="info"]').html()+"</div>"
              
            arr.forEach (num, idx) =>
              item = $(el).find('div[data-type="option"]').eq(num)
              if item.data('correct')
                sct[idx] = 1
              input.append "<div class='amalthea_quiz_option' data-action='check'><span class='checkbox'></span><span>"+item.html()+"</span></div>"
            cell.set_sct sct
          else if lang is 'blank'
            sct = []
            str = $(el).find('div[data-type="string"]').html()
            str = str.replace(/%b/g,'<input type="text" class="amalthea_quiz_blank">')
            input.append "<div class='amalthea_quiz_info'>"+str+"</div>"
            $(el).find('div[data-type="blank"]').each (idx, item) =>
              sct.push($(item).text().trim().split(','))
            cell.set_sct sct
              
          wrap = $("<div class='amalthea_wrap' data-cell-id='#{i}'></div>")
          if title
            titlebox = $("<div class='amalthea_title' data-cell-id='#{i}'></div>")
            titlebox.append "<div class='amalthea_title_controls' data-cell-id='#{i}'><span class='code-type'>#{langStr.title}</span><button data-action='reset' class='reset'>" + locale['RESET'] + "</button></div>"
            titlebox.append "<div class='amalthea_title_text'><span>#{title}</span></div>"
            wrap.append titlebox
          hint = $("<div class='amalthea_hint' data-cell-id='#{i}' style='display:none'></div>")
          solution = $("<div class='amalthea_solution' data-cell-id='#{i}' style='display:none'></div>")
          message = $("<div class='amalthea_message' data-cell-id='#{i}' style='display:none' onclick='{this.style.display="+'"none"'+"}'></div>")

          if $(el).is(@options.not_executable_selector)
            @not_execute[i] = true
          else
            @not_execute[i] = false
          controls = $("<div class='amalthea_controls' data-cell-id='#{i}'>#{@controls_html_quiz(cell,i)}</div>")

          $(el).replaceWith(cell.element.empty().append(wrap))
          @cells.push cell
          
          $(wrap).append input
          $(wrap).append hint
          $(wrap).append solution
          $(wrap).append message
          $(wrap).append controls
          
          @notebook_el.hide()
              
          return
        
        cell = @notebook.insert_cell_at_bottom('code')
        original_id = $(el).attr('id')
        autorun = $(el).attr('autorun')
        # autorun = true
        # grab pre exercise code
        title = $(el).find('code[data-type="title"]').text().trim()
        cell.set_title title
        # grab program title
        pretext = $(el).find('code[data-type="pre-exercise-code"]').text().trim()
        cell.set_pretext pretext
        # grab sample text
        cell.set_samplecode $(el).find('code[data-type="sample-code"]').text().trim()
        # grab text, trim it, put it in cell
        cell.set_text $(el).find('code[data-type="sample-code"]').text().trim()
        # grab solution code
        cell.set_solution $(el).find('code[data-type="solution"]').text().trim()
        # grab sct code
        cell.set_sct $(el).find('code[data-type="sct"]').text().trim()
        # grab sct method
        cell.set_sct_method $(el).find('code[data-type="sct"]').data('method')      
        # grab hint code
        cell.set_hint $(el).find('code[data-type="hint"]').text().trim()
        # set language
        cell.set_lang lang
        langStr = cell.get_lang();
        cell.force_highlight(langStr.mode)
        # is this a read only cell
        if $(el).is(@options.read_only_selector)
          # not really used by the notebooks it seems, but is present in cell.js
          cell.read_only = true
          # this actually sets cm to read only mode
          cell.code_mirror.setOption("readOnly", true) # or "nocursor", though that prevents focus
        # Add run button, wrap it all up, and replace the pre's
        wrap = $("<div class='amalthea_wrap' data-cell-id='#{i}'></div>")
        if $(el).attr('data-not-executable') != undefined
          wrap.addClass('not-executable')
        if $(el).attr('data-read-only') != undefined
          wrap.addClass('read-only')
        if title
          titlebox = $("<div class='amalthea_title' data-cell-id='#{i}'></div>")
          titlebox.append "<div class='amalthea_title_controls' data-cell-id='#{i}'><span class='code-type'>#{langStr.title}</span><button data-action='reset' class='reset'>" + locale['RESET'] + "</button><button data-action='copy' class='copy'>" + locale['COPY'] + "</button></div>"
          titlebox.append "<div class='amalthea_title_text'><span>#{title}</span></div>"
          wrap.append titlebox
        if pretext
          pretextbox = $("<div class='amalthea_pretext' data-cell-id='#{i}'></div>")
          wrap.append pretextbox
        outputbox = $("<div class='amalthea_output' data-cell-id='#{i}' style='display:none'></div>")
        outputbox.append $("<div class='amalthea_output_area'></div>")
        hint = $("<div class='amalthea_hint' data-cell-id='#{i}' style='display:none'></div>")
        solution = $("<div class='amalthea_solution' data-cell-id='#{i}' style='display:none'></div>")
        message = $("<div class='amalthea_message' data-cell-id='#{i}' style='display:none' onclick='{this.style.display="+'"none"'+"}'></div>")
        
        if $(el).is(@options.not_executable_selector)
          @not_execute[i] = true
        else
          @not_execute[i] = false
        controls = $("<div class='amalthea_controls' data-cell-id='#{i}'>#{@controls_html(cell,i)}</div>")
        
        wrap.append cell.element.children()
        $(el).replaceWith(cell.element.empty().append(wrap))
        # cell.refresh() # not needed currently, but useful
        @cells.push cell
        unless @server_error
          $(wrap).append outputbox
          $(wrap).append hint
          $(wrap).append solution
          $(wrap).append message
          $(wrap).append controls

        cell.element.attr('id', original_id) if original_id
        cell.element.removeAttr('tabindex')
        # otherwise cell.js will throw an error
        cell.element.off 'dblclick'
        cell.element.click()
        
        @typing[i] = false
        if autorun
          cell.set_text ""
          cell.read_only = true
          cell.code_mirror.setOption("readOnly", true)
          @typing[i] = true
          setTimeout(()=>
              @autorun i
            , 600)

      # We're not using the real notebook
      @notebook_el.hide()
      
      # Keyboard events
      $('div.code_cell').off 'keydown'
      $('div.code_cell').on 'keydown', (e)=>
        if e.which is @options.next_cell_shortcut and e.shiftKey is true
          cell_id = get_cell_id_from_event(e)
          # at the end? wrap around
          if cell_id is @cells.length-1 then cell_id = -1
          next = @cells[cell_id+1]
          next.focus_editor()
          # don't insert space or whatever
          return false
        else if e.which is @options.run_cell_shortcut and e.shiftKey is true
          cell_id = get_cell_id_from_event(e)
          @run_cell(cell_id)
          # don't insert a CR or whatever
          return false
        # finally, this is just for metrics
        else if focus_edit_flag
          cell_id = get_cell_id_from_event(e)
          @track 'cell_edit', {cell_id: cell_id}
          focus_edit_flag = false
        # XXX otherwise code will be uneditable!
        return true

      if not action
        
        # Just to get metric on which cells are being edited
        # The flag ensures we only send once per focus, but only on edit
        focus_edit_flag = false
        # Triggered when a cell is focused on
        @events.on 'edit_mode.Cell', (e, c)=>
          focus_edit_flag = true

        # Helper for below
        get_cell_id_from_event = (e)-> $(e.currentTarget).find('.amalthea_controls').data('cell-id')

        # Interrupt on ctrl-c, because terminal
        $(window).on 'keydown', (e)=>
          if e.which is 67 and e.ctrlKey then @kernel.interrupt()

        # Used for a successful reconnection
        @events.on 'kernel_connected.Kernel', =>
          # Empty string = already connected but lost it
          if @has_kernel_connected is ''
            for cell, id in @cells
              # Reset all the buttons to run or run again
              @show_cell_state(@idle_state, id)

        @events.on 'kernel_idle.Kernel', =>
          # set idle state outside of poll, doesn't effect ui
          @set_state @idle_state
          # then poll to make sure we're still idle before changing ui
          $.doTimeout 'amalthea_idle_state', 300, =>
            if @state is @idle_state
              busy_ids = $(".amalthea_controls button[data-state='busy']").parent().map(->$(this).data('cell-id'))
              # just the busy ones, doesn't do it on reconnect
              for id in busy_ids
                @show_cell_state(@idle_state, id)

              # Get rid of the traceback output generated for user interrupt
              interrupt_ids = $(".amalthea_controls button[data-state='interrupt']").parent().map(->$(this).data('cell-id'))
              for id in interrupt_ids
                @cells[id]["output_area"].clear_output(false)

              return false
            else if @state not in @error_states
              # keep polling
              return true
            else return false

        @events.on 'kernel_busy.Kernel', =>
          @set_state(@busy_state)

        # We use this instead of 'kernel_disconnected.Kernel'
        # because the kernel always tries to reconnect
        @events.on 'kernel_reconnecting.Kernel', (e, data)=>
          @log 'Reconnect attempt #'+ data.attempt
          if data.attempt < 1
            time = Math.pow 2, data.attempt
            @set_state(@disc_state, time)
          else
            @set_state(@gaveup_state)

        # This listens to a custom event I added in outputarea.js's handle_output function
        @events.on 'output_message.OutputArea', (e, msg_type, msg, output_area)=>
          controls = $(output_area.element).parents('.code_cell').find('.amalthea_controls')
          id = controls.data('cell-id')
          @log msg
          if msg_type is 'error'
            if @cells[id].get_sct()
              @show_message(false, id)
            # $.doTimeout 'amalthea_idle_state'
            @log 'Error executing cell #'+id
            @log msg.content
            if msg.content.ename is "KeyboardInterrupt"
              @log "KeyboardInterrupt by User"
              @show_cell_state(@interrupt_state, id)
            else
              @show_cell_state(@user_error, id)
            $(".amalthea_output[data-cell-id=#{id}]").show().children().append('<pre>' + msg.content.ename + ':\n' + msg.content.evalue + '</pre>')
          else if msg_type is 'execute_result'
            if @cells[id].get_sct() && @cells[id].get_sct_method() == 0
              if msg.content && ( msg.content.data["text/plain"] == "True" || msg.content.data["text/plain"] == "true" )
                @show_message(true, id)
              else
                @show_message(false, id)
            else
              if msg.content.data['image/png']
                $(".amalthea_output[data-cell-id=#{id}]").show().children().append(msg.content.data['image/png'])
              else if msg.content.data['text/html']
                $(".amalthea_output[data-cell-id=#{id}]").show().children().append(msg.content.data['text/html'])
              else
                $(".amalthea_output[data-cell-id=#{id}]").show().children().append('<pre>' + msg.content.data['text/plain'] + '</pre>')
          else if msg_type is 'stream'
            if msg.content.name is 'stdout'
              $(".amalthea_output[data-cell-id=#{id}]").show().children().append('<pre>' + (new ansi_up.default).ansi_to_html(msg.content.text) + '</pre>')
              if @cells[id].get_sct() && @cells[id].get_sct_method() == 1
                if msg.content.text.trim() == @cells[id].get_sct()
                  @show_message(true, id)
                else
                  @show_message(false, id)
          else if msg_type is 'display_data'
            if msg.content.data['image/png']
              $(".amalthea_output[data-cell-id=#{id}]").show().children().append('<img src="data:image/png;base64,' + msg.content.data['image/png'] + '">')
            else if msg.content.data['text/html']
              $(".amalthea_output[data-cell-id=#{id}]").show().children().append(msg.content.data['text/html'])

    autorun: (id) =>
      if @typing[id] isnt true
        return
      cell = @cells[id]
      start = cell.get_text().length
      str = cell.get_samplecode()
      if start < str.length
        start += parseInt(str.length / 16)
        cell.set_text str.slice(0, start)
        setTimeout(()=>
            @autorun id
          , Math.random()*100+100)
      else if start > 0
        @typing[id] = false
        @run_cell(id)
        cell.read_only = false
        cell.code_mirror.setOption("readOnly", false)
        $(".amalthea_wrap[data-cell-id=#{id}]").removeClass('read-only')
        
          
    # USER INTERFACE
    # ----------------------
    #
    # This doesn't change the html except for the error states
    # Otherwise it only sets the @state variable
    set_state: (@state, reconnect_time='') =>
      @log 'Amalthea: '+@state
      if @state in @error_states
        html = @ui[@state]
        $(".amalthea_controls").each (i, el) =>
          $(el).html @controls_html(@cells[$(el).data('cell-id')], $(el).data('cell-id'), @state, html)

        if @state is @disc_state
          $(".amalthea_controls button").prop('disabled', true)

    show_cell_state: (state, cell_id)=>
      @set_state(state)
      @log 'show cell state: '+ state + ' for '+ cell_id
      # has this cell already been run and we're switching it to idle
      if @cells[cell_id]['last_msg_id'] and state is @idle_state
        state = @ran_state
      $(".amalthea_controls[data-cell-id=#{cell_id}]").html @controls_html(@cells[cell_id], cell_id, state)

    # Basically a template
    # Note: not @state
    controls_html: (cell=undefined, cell_id=0, state=@idle_state, html=false)=>
      if @not_execute[cell_id]
        return ""
      if not html then html = @ui[state]
      result = "<button data-action='run' data-state='#{state}'>#{html}</button>"
      if @options.add_interrupt_button and state is @busy_state # and state is running??
        result+="<button data-action='interrupt'>" + locale['INTERRUPT'] + "</button>"
      if state is @user_error
        result+=@ui["error_addendum"]
      if cell && cell.get_hint() && not cell.showHint && not cell.showSolution
        result+="<button data-action='showhint' class='hint'>" + locale['SHOWHINT'] + "</button>"
      else if cell && cell.get_hint() && cell.showHint && not cell.showSolution
        result+="<button data-action='showhint' class='solution'>" + locale['SHOWANS'] + "</button>"
      else if cell && cell.get_hint() && cell.showSolution
        result+="<button data-action='showhint' class='solution'>" + locale['HIDEANS'] + "</button>"
      result+='<a href="https://amalthea.ai" target="_blank"><div class="poweredby-amalthea"></div></a>'
      result
      
    controls_html_quiz: (cell=undefined, cell_id=0, state=@idle_state, html=false)=>
      if @not_execute[cell_id]
        return ""
      if not html then html = @ui[state]
      result = "<button data-action='run'>" + locale['SUBMIT'] + "</button>"
      if cell && cell.get_hint() && not cell.showHint && not cell.showSolution
        result+="<button data-action='showhint' class='hint'>" + locale['SHOWHINT'] + "</button>"
      else if cell && cell.get_hint() && cell.showHint && not cell.showSolution
        result+="<button data-action='showhint' class='solution'>" + locale['SHOWANS'] + "</button>"
      else if cell && cell.get_hint() && cell.showSolution
        result+="<button data-action='showhint' class='solution'>" + locale['HIDEANS'] + "</button>"
      result+='<a href="#" target="_blank"><div class="poweredby-amalthea"></div></a>'
      result

    get_controls_html: (cell)=>
      $(cell.element).find(".amalthea_controls").html()

    # Basically a template
    kernel_controls_html: ->
      "<button data-action='run-above'>全部运行</button> <button data-action='interrupt'>中断</button> <button data-action='restart'>重新运行</button>"

    # EVENTS
    # ----------------------
    #
    # User clicks a run button, end_id is for the run above feature
    # The combo of the callback and range makes it a little awkward
    run_cell: (cell_id, end_id=false)=>
      lang = @cells[cell_id].get_lang().lang
      if lang is 'single' or lang is 'multiple' or lang is 'blank'
        if lang is 'single' or lang is 'multiple' 
          if not $(".amalthea_quiz[data-cell-id=#{cell_id}]").find('.amalthea_quiz_option.selected').length
            return
          sct = @cells[cell_id].get_sct()
          items = $(".amalthea_quiz[data-cell-id=#{cell_id}]").find('.amalthea_quiz_option')
          correct = true
          items.removeClass('right').removeClass('wrong')
          sct.forEach (node, idx) => 
            if items.eq(idx).hasClass('selected') and !node 
              correct = false
            else if !items.eq(idx).hasClass('selected') and node
              correct = false
          @show_message(correct, cell_id)
        else
          sct = @cells[cell_id].get_sct()
          correct = true
          items = $(".amalthea_quiz[data-cell-id=#{cell_id}]").find('.amalthea_quiz_blank')
          items.each (idx, node) =>
            if not sct[idx].includes($(node).val().trim())
              correct = false
          @show_message(correct, cell_id)
        return
      if @typing[cell_id]
        return
      if $(".amalthea_output[data-cell-id=#{cell_id}]").parent().find('.CodeMirror-line').text() is ""
        return
      $(".amalthea_output[data-cell-id=#{cell_id}]")
        .hide()
        .children()
        .html('')
      $(".amalthea_message[data-cell-id=#{cell_id}]").hide()
      @track 'run_cell', {cell_id: cell_id, end_id: end_id}

      # This deals with when we allow a user to try to call spawn again after a disconnect
      # A bit confusing, because @error_states contains gaveup and cant
      # but we don't want it to count in this special case, because we're
      # starting over after a disconnect
      if @state in [@gaveup_state, @cant_state]
        @log 'Lets reconnect amalthea to the server'
        # Reset flags, using blank string to be falsy
        # but different from the initial value of @has_kernel_connected
        @has_kernel_connected = ''
        # and this will cause us to call_spawn
        @url = ''

      # If we're still trying to reconnect to the same url
      # or we're already starting up, just return
      else if @state in @error_states.concat(@start_state)
        @log 'Not attempting to reconnect amalthea to server, state: '+ @state
        return

      # The actual run cell logic, depends on if we've already connected or not
      cell = @cells[cell_id]

      if not @get_controls_html(cell) then return

      if not @has_kernel_connected
        @show_cell_state(@start_state, cell_id)
        # pass the callback to before_first_run
        # which will pass it either to start_kernel or call_spawn
        @before_first_run cell, =>
          @show_cell_state(@busy_state, cell_id)
          cell.execute(true)
          if end_id
            for cell, i in @cells[cell_id+1..end_id]
              if not @get_controls_html(cell) then continue
              @show_cell_state(@busy_state, i+1)
              cell.execute(true)
      else if @kernel.name != cell.get_lang().kernel
        @log "Turn to kernel "+ cell.get_lang().kernel
        @show_cell_state(@start_state, cell_id)
        @kernel.kill()
        @has_kernel_connected = false
        @before_first_run cell, =>
          @show_cell_state(@busy_state, cell_id)
          cell.execute(true)
          if end_id
            for cell, i in @cells[cell_id+1..end_id]
              if not @get_controls_html(cell) then continue
              @show_cell_state(@busy_state, i+1)
              cell.execute(true)
      else
        @show_cell_state(@busy_state, cell_id)
        cell.execute(true)
        if end_id
          for cell, i in @cells[cell_id+1..end_id]
            if not @get_controls_html(cell) then continue
            @show_cell_state(@busy_state, i+1)
            cell.execute(true)

    show_message: (b, id) =>
      $(".amalthea_message[data-cell-id=#{id}]").hide()
      if b 
        $(".amalthea_message[data-cell-id=#{id}]")
          .text locale['SUCCESS']
          .removeClass "message_wrong"
          .addClass "message_right"
          if @handler
            event = new CustomEvent("amalthea.checked", { 'detail':{'result': 'right', 'id': id} });
            @handler.node.dispatchEvent event
      else
        $(".amalthea_message[data-cell-id=#{id}]")
          .text locale['FAIL']
          .removeClass "message_right"
          .addClass "message_wrong"
          if @handler
            event = new CustomEvent("amalthea.checked", { 'detail':{'result': 'wrong', 'id': id} });
            @handler.node.dispatchEvent event
      setTimeout(()=>
          $(".amalthea_message[data-cell-id=#{id}]").show()
        , 100)
        
    # Note, we don't call the callback here, just pass it on
    before_first_run: (cell, cb) =>
      if @url then @start_kernel(cell, cb)
      else @call_spawn(cell, cb)

      if @options.append_kernel_controls_to and not $('.kernel_controls').length
        kernel_controls = $("<div class='kernel_controls'></div>")
        kernel_controls.html(@kernel_controls_html()).appendTo @options.append_kernel_controls_to

    setup_user_events: ->
      # main click handler
      $('body').on 'click', 'div.amalthea_controls button, div.kernel_controls button, div.amalthea_title_controls button, .amalthea_quiz_option', (e)=>
        e.preventDefault()
        button = $(e.currentTarget)
        id = button.parent().data('cell-id')
        action = button.data('action')
        if e.shiftKey
          action = 'shift-'+action
        switch action
          when 'run'
            @run_cell(id)
          when 'shift-run', 'run-above'
            if not id then id = @cells.length
            @log 'exec from top to cell #'+id
            @run_cell(0, id)
          when 'interrupt'
            @kernel.interrupt()
          when 'restart'
            if confirm('Are you sure you want to restart the kernel? Your work will be lost.')
              @kernel.restart()
          when 'showhint'
            @showhint(id, button)
          when 'reset'
            @resetcode(id, button)
          when 'copy'
            @copycode(id, button)
          when 'select'
            button.parent().find('.amalthea_quiz_option').removeClass('selected')
            button.addClass('selected')
          when 'check'
            if button.hasClass('selected')
              button.removeClass('selected')
            else
              button.addClass('selected')
        
    showhint: (cell_id, e)=>
      cell = @cells[cell_id]
      if not cell.showHint && not cell.showSolution
        ele = $('.amalthea_hint[data-cell-id="'+cell_id+'"]')
        ele.html '<div class="amalthea_hint_area"><div>' + cell.get_hint() + '</div></div>'
        ele.css "display","block"
        cell.showHint = true
        e.html locale['SHOWANS']
        e.removeClass "hint"
        e.addClass "solution"
      else if cell.showHint && not cell.showSolution
        ele = $('.amalthea_hint[data-cell-id="'+cell_id+'"]')
        ele.html ''
        ele.css "display","none"
        ele = $('.amalthea_solution[data-cell-id="'+cell_id+'"]')
        ele.html '<div class="amalthea_solution_area"><pre>' + cell.get_solution() + '</pre></div>'
        ele.css "display","block"
        cell.showHint = false
        cell.showSolution = true
        e.html locale['HIDEANS']
      else
        ele = $('.amalthea_solution[data-cell-id="'+cell_id+'"]')
        ele.html ''
        ele.css "display","none"
        cell.showSolution = false
        e.html locale['SHOWHINT']
        e.removeClass "solution"
        e.addClass "hint"
        
    resetcode: (cell_id, button)=>
      cell = @cells[cell_id]
      if cell.get_lang().lang is 'single' or cell.get_lang().lang is 'multiple' or cell.get_lang().lang is 'blank'
        $('.amalthea_quiz[data-cell-id="'+cell_id+'"]').find('input').val('')
        $('.amalthea_quiz[data-cell-id="'+cell_id+'"]').find('.amalthea_quiz_option').removeClass('selected')
        $('.amalthea_message[data-cell-id="'+cell_id+'"]').hide()
        return
      if cell.reset_text
        cell.reset_text()
      
    copycode: (cell_id, button)=>
      cell = @cells[cell_id]
      node = $("<textarea></textarea>").css('position','absolute').css('opacity','0').val(cell.get_text()).appendTo($('body')).select()
      document.execCommand("copy")
      node.remove()
      cell.focus()
      cell.select_all()
      
    start_kernel: (cell, cb)=>
      @log 'start_kernel with '+@url
      kernel_name = cell.get_lang().kernel;
      @kernel = new kernel.Kernel @url+'api/kernels', '', @notebook, kernel_name
      # hack to fix changes in v4 in kernel selector, this was an object instead
      @kernel.name = kernel_name
      # start it
      @kernel.start()
      @notebook.kernel = @kernel
      @events.off 'kernel_ready.Kernel'
      @events.on 'kernel_ready.Kernel', =>
        @has_kernel_connected = true
        @log 'kernel ready'
        for n_cell, i in @cells
          if n_cell.get_lang().kernel == kernel_name
            n_cell.set_kernel @kernel
        cb()

    # This sets up the jupyter notebook frontend
    # Stubbing a bunch of stuff we don't care about and would throw errors
    start_notebook: =>
      contents =
        list_checkpoints: -> new Promise (resolve, reject) -> resolve {}
      keyboard_manager =
        edit_mode: ->
        command_mode: ->
        register_events: ->
        enable: ->
        disable: ->
      keyboard_manager.edit_shortcuts = handles: ->
      save_widget =
        update_document_title: ->
        contents: ->
      config_section =  {data: {data:{}}}
      common_options =
        ws_url: ''
        base_url: ''
        notebook_path: ''
        notebook_name: ''

      @notebook_el = $('<div id="notebook"></div>').prependTo(@options.container_selector)

      @notebook = new (notebook.Notebook)('div#notebook', $.extend({
        events: @events
        keyboard_manager: keyboard_manager
        save_widget: save_widget
        contents: contents
        config: config_section
        codemirror_theme_name: @options.codemirror_theme_name
      }, common_options))

      @notebook.kernel_selector =
        set_kernel : ->

      @events.trigger 'app_initialized.NotebookApp'
      @notebook.load_notebook common_options.notebook_path, @options.codemirror_mode_name
      IPython.notebook = @notebook
      # And finally
      @build_amalthea()

    destroy: =>
      if @kernel then @kernel.interrupt()
      
    shuffle: (a) ->
      j = undefined
      x = undefined
      i = undefined
      i = a.length
      while i
        j = Math.floor(Math.random() * i)
        x = a[i - 1]
        a[i - 1] = a[j]
        a[j] = x
        i--
      return
	
    get_param_from_qs: (name)->
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
        regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
        results = regex.exec(location.search)
        if results == null then '' else decodeURIComponent(results[1].replace(/\+/g, ' '))

    log: (m, serious=false)->
      if @debug
        if not serious then console.log(m);
        else console.log("%c#{m}", "color: blue; font-size: 12px");
      else if serious then console.log(m)

    track: (name, data={})=>
      data['name'] = name
      if @server_error then data['server_error'] = true
      if @has_kernel_connected then data['has_kernel_connected'] = true
      $(window.document).trigger 'amalthea_tracking_event', data
  
  # window.Amalthea = Amalthea

  return {Amalthea: Amalthea}
