HideTreeView = require './hide-tree-view'
{CompositeDisposable} = require 'atom'
{requirePackages} = require 'atom-utils'
module.exports = HideTree =
  hideTreeView: null
  modalPanel: null
  subscriptions: null
  config:
    focus:
      title: 'Hide on Focus'
      type: 'boolean'
      default: false
    animateTime:
      title: 'Animation Time'
      type: 'integer'
      minimum: 50
      default: 100
    timeout:
      title: 'Hide on MouseOut'
      type: 'integer'
      minimum: 100
      default: 500


  activate: (state) ->
    # console.log 'In the acitvate state',state
    @hideTreeView = new HideTreeView(state.locked)
    if atom.config.get('tree-view.showOnRightSide')
      @modalPanel = atom.workspace.addRightPanel item:@hideTreeView
    else
      @modalPanel = atom.workspace.addLeftPanel item:@hideTreeView

    # # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    # @subscriptions = new CompositeDisposable
    #
    # # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'hide-tree:toggle': => @toggle()
  deactivate: ->
    @hideTreeView.destroy()
    # @modalPanel.destroy()
    # @subscriptions.dispose()

  serialize: ->
    locked: @hideTreeView.locked
    # console.log 'sericalized',@hideTreeView.locked
