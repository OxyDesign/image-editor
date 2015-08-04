'use strict'

class ImageEditor
  constructor: (config={}) ->
    return if not (config.elt or config.pic)

    self = @

    self.config = config

    elt = self.config.elt

    self.canvas = elt.querySelector 'canvas'
    self.btLeft = elt.querySelector '.bt-left'
    self.btRight = elt.querySelector '.bt-right'
    self.btLess = elt.querySelector '.bt-less'
    self.btMore = elt.querySelector '.bt-more'
    self.btSave = elt.querySelector '.bt-save'
    self.doc = document

    self.context = self.canvas.getContext '2d'

    self.picture = new Image()
    self.picture.setAttribute 'crossOrigin', 'anonymous'
    self.picture.src = self.config.pic

    self.picture.onload = ->
      self.init()

  init : ->
    self = @

    self.btLeft.addEventListener 'click', self.turnLeft.bind(self), false
    self.btRight.addEventListener 'click', self.turnRight.bind(self), false
    self.btLess.addEventListener 'click', self.zoomOut.bind(self), false
    self.btMore.addEventListener 'click', self.zoomIn.bind(self), false
    self.btSave.addEventListener 'click', self.saveImage.bind(self), false

    self.context.drawImage self.picture, 0, 0, 240, 240

    self.initialized = true

  update : (pic) ->
    self = @

    self.picture = new Image()
    self.picture.setAttribute 'crossOrigin', 'anonymous'
    self.picture.src = pic

    self.context.drawImage self.picture, 0, 0, 240, 240

  turnLeft : ->
    self = @
    console.log 'turnLeft'

  turnRight : ->
    self = @
    console.log 'turnRight'

  zoomOut : ->
    self = @
    console.log 'zoomOut'

  zoomIn : ->
    self = @
    console.log 'zoomIn'

  saveImage : ->
    self = @
    console.log 'saveImage'
