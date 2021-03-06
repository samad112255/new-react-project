{__, classSet}= React.Helpers
{Icon, Dialog, Modal, ModalBody, Row, Col}= require 'bootstrap'
sizeOf= require 'lib/size-of'

###
  Public: A debug panel (as a Bootstrap Modal)
###
class DialogPanel extends React.Component

  mixins: [ Dialog.mixin ]

  getInitialState: ->
    data= @props.source or app.state.get()
    source: data
    expanded: []

  actionToggleExpanded: (path, e)->
    # console.log 'toggle', path
    if path in @state.expanded
      @setState expanded:(key for key in @state.expanded when key isnt path)
    else
      @state.expanded.push path
      @forceUpdate()
    cancelEvent e

  render: ->
    # console.log  @state.expanded
    maxHeight= $(window).height() - 100 #150
    data= @state.source
    (Modal titleLabel:'Debug Information', size:'large',
      (ModalBody className:'debug-graph', style:{ maxHeight:maxHeight, overflow:'auto' },
        (Row __,
          (Col xs:'8',
            (@h3 style:{ marginTop:0 }, 
              "App.State Graph"
              (@small __, " ~#{ sizeOf data  } in memory")
            )
            (@ul __,
             (@renderChildren data, '', 1)
            )
          )
          (Col xs:'4',
            (@h3 style:{ marginTop:0 }, "Listeners")
            (@pre className:'listener-summary', app.state._listenerSummary())
          )
        )
      )
    )

  renderChildren: (data, path, level)->
    # console.log 'rendering', data
    elems= []
    for key, i in Object.keys(data)
      try
        # console.log key, data[key]
        val= data[key]
        dataType= type(val)
        childPath = if path is ''
          key
        else
          "#{ path }.#{ key }"
        expand= if childPath in @state.expanded then yes else no
        hasChildren= (dataType is 'object' or dataType is 'array')
        clsx= classSet
          expanded: expand
          collapsed: not expand
          'has-children': hasChildren
          'no-children': not hasChildren
        cls= "#{ clsx } #{ dataType }"
        children= if (dataType is 'object' or dataType is 'array') and expand
            # (Node source:val)
            (@ul __, @renderChildren(val, childPath, level + 1))
          else
            null
        handler= if hasChildren
            @actionToggleExpanded.bind @, childPath
          else
            null
        desc= if dataType is 'object' 
            (@label className:cls, onClick:handler, dataType, " {", Object.keys(val).length ,"}")
          else if dataType is 'array'
            (@label className:cls, onClick:handler, dataType, " [", val.length ,"]")
          else
            (@label className:cls, String(val))
        toggle= if hasChildren
          icon= if expand then 'angle-down' else 'angle-right'
          (@span className:'toggler',
            (Icon fa:icon, onClick:handler)
          )
        else
          (@span className:'toggler',
            ' '
          )

        item= (@li 
          key:"#{ level }-#{ key }"
          className:cls
          (@div className:'props', onClick:handler,
            (toggle)
            (@code __, key)
            (desc)
          )
          (children)
        )
        elems.push item
      catch ex
        console.error ex
    elems

module.exports= DialogPanel.reactify()
