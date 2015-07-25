{View,$} = require("atom-space-pen-views")
{requirePackages} = require 'atom-utils'
module.exports =
class HideTreeView extends View
  constructor: (@locked=false)->
    @toggleAnim = atom.config.get('hide-tree.animate')
    super
  @content: ->
    rightSide = atom.config.get('tree-view.showOnRightSide')
    @div class:'hide-tree', =>
      @span class:'mega-octicon octicon-lock',outlet:'lock'
      @div class:'gutter', outlet:'gutter'
      @span class:'mega-octicon octicon-move-left',outlet:'left'
      @span class:'mega-octicon octicon-move-right',outlet:'right'

  initialize: ->
    @lock.toggleClass 'active',@locked
    requirePackages('tree-view').then ([treeView]) =>
      if treeView.treeView and treeView.treeView.isVisible() and treeView.treeView.width() # we can open only if it closed.
        @closed = false
        @gutter.hide()
      else
        @closed = true
      @initializeTree treeView.treeView
    rightSide = atom.config.get('tree-view.showOnRightSide')
    @toggleClass('right',rightSide)
    @left.on 'click', (evt)=>
      return unless atom.config.get('tree-view.showOnRightSide')
      atom.commands.dispatch(atom.workspaceView[0],'tree-view:toggle-side')
      panelView = @parent().parent()
      @toggleClass('right',false)
      @left.hide()
      @right.show()
      panelView.parent().prepend(panelView)

    @right.on 'click', (evt)=>
      return if atom.config.get('tree-view.showOnRightSide')
      atom.commands.dispatch(atom.workspaceView[0],'tree-view:toggle-side') if atom.workspaceView?[0]?
      panelView = @parent().parent()
      @toggleClass('right',true)
      @right.hide()
      @left.show()
      panelView.parent().append(panelView)

    if rightSide
      @right.hide()
      @left.show()
    else
      @left.hide()
      @right.show()

    @gutter.on 'mouseover', (evt)=>
      return if @locked
      if @treeView
        @openTree $(` this`)
      else
        requirePackages('tree-view').then ([treeView]) =>
          self = $(` this`)
          @openTree(self) if @initializeTree treeView.treeView

    @lock.on 'click', (evt)=>
      @locked = !@locked
      $(` this`).toggleClass 'active',@locked

  initializeTree: (@treeView)->
    unless @treeView
      atom.commands.dispatch(atom.views.getView(atom.workspace),'tree-view:toggle')
      setTimeout =>
        requirePackages('tree-view').then ([treeView]) =>
          if treeView?.treeView
            @treeView = treeView.treeView
            if atom.config.get 'hide-tree.focus'
              @focusWatch()
            else
              @timerWatch()
              @treeView.toggle() if @treeView.isVisible() and @gutter.isVisible()
      ,1000
      return false
    @treeView.toggle() if @treeView.isVisible() and @gutter.isVisible() and not atom.config.get('hide-tree.focus')
    if atom.config.get 'hide-tree.focus'
      @focusWatch()
    else
      @timerWatch()
    return true

  openTree: (self)->
      if @treeView.width() and @treeView.isVisible() # we can open only if it closed.
        @closed = false
        self.hide()
        return
      self.hide()
      @closed = false
      @treeView.toggle()
      width = @treeView.width()
      if width
        @treeView.css width:'0'
        @treeView.animate {width:width},atom.config.get('hide-tree.animateTime'), ->
      unless atom.config.get 'hide-tree.focus'
        @timerWatch() unless @treeWatched

  focusWatch: ->
    atom.workspace.observeTextEditors (editor)=>
      view = atom.views.getView(editor)
      # debugger
      # scrollView = view.shadowRoot.querySelector('.scroll-view')
      # scrollView?.addEventListener  'click', =>
      view?.addEventListener  'click', =>
          @closeTree() if @treeView
          view.focus()

  timerWatch: ->
      return unless @treeView
      timer = null
      @treeWatched = true
      @treeView.on 'mouseover', =>
        return if @locked
        clearTimeout timer

      @lock.on 'mouseover', ->
        clearTimeout timer

      @treeView.on 'mouseout', =>
        return if @locked
        timer = setTimeout =>
          @closeTree()
        ,atom.config.get('hide-tree.timeout')

  closeTree: ->
      if @treeView and @treeView.width() and @treeView.isVisible()
        @closed = false if @closed
      else
        unless @closed
          @closed = true
          @gutter.show()
          return
      return if @locked or @closed
      @closed = true
      width = @treeView.width()
      @treeView.animate {width:0},atom.config.get('hide-tree.animateTime'), =>
        @treeView.css width: width
        @treeView.toggle()
        $(@gutter).show()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @remove()
