module.exports = HideTree =
  hideTreeView: null
  modalPanel: null
  config:
    focus:
      title: 'Hide on Focus'
      type: 'boolean'
      default: true
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
    HideTreeView = require './hide-tree-view'
    @hideTreeView = new HideTreeView(state.locked)
    if atom.config.get('tree-view.showOnRightSide')
      @modalPanel = atom.workspace.addRightPanel item:@hideTreeView
    else
      @modalPanel = atom.workspace.addLeftPanel item:@hideTreeView

  deactivate: ->
    @hideTreeView.destroy()
    @modalPanel.destroy()

  serialize: ->
    locked: @hideTreeView.locked
