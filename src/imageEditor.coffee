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

    self.cnvW = self.canvas.width
    self.cnvH = self.canvas.height
    self.cnvRatio = self.canvas.height/self.canvas.width

    self.cnvHalfW = self.cnvW/2
    self.cnvHalfH = self.cnvH/2
    self.cnvClearPx = -self.cnvW
    self.cnvClearPy = -self.cnvH
    self.cnvClearW = self.cnvW*2
    self.cnvClearH = self.cnvH*2
    self.currentAngle = 0
    self.newAngle = 0
    self.toRad = Math.PI/180
    self.zoom = 1.1
    self.currentZoom = 1
    self.maxZoom = 20

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

    self.canvas.addEventListener 'mousedown', self.dragStart.bind(self), false
    self.doc.addEventListener 'mouseup', self.dragStop.bind(self), false

    self.imgSettings()

    self.context.translate self.cnvHalfW, self.cnvHalfH
    self.context.save()
    self.drawImage()

    self.initialized = true

  update : (pic) ->
    self = @

    self.context.rotate self.toRad*-self.currentAngle

    self.currentAngle = 0
    self.newAngle = 0
    self.currentZoom = 1

    self.picture = new Image()
    self.picture.setAttribute 'crossOrigin', 'anonymous'
    self.picture.src = pic

    self.imgSettings()

    self.context.restore()
    self.drawImage()

  imgSettings : ->
    self = @

    self.picRatio = self.picture.height/self.picture.width
    pictureLandscape = self.picRatio < 1

    self.imgW = if pictureLandscape then self.cnvW/self.picRatio else self.cnvW
    self.imgH = if pictureLandscape then self.cnvH else self.cnvH*self.picRatio

    self.imgPx = -self.imgW/2
    self.imgPy = -self.imgH/2

  turnLeft : ->
    self = @
    self.animation and clearInterval self.animation
    self.newAngle -= 90
    self.rotation()

  turnRight : ->
    self = @
    self.animation and clearInterval self.animation
    self.newAngle += 90
    self.rotation()

  zoomOut : ->
    self = @
    return if self.currentZoom <= 1
    self.imgW /= self.zoom
    self.imgH /= self.zoom
    self.currentZoom--
    self.drawImage()

  zoomIn : ->
    self = @
    return if self.currentZoom > self.maxZoom
    self.imgW *= self.zoom
    self.imgH *= self.zoom
    self.currentZoom++
    self.drawImage()

  dragStart : (e) ->
    self = @
    e.preventDefault()

    self.direction = ((self.newAngle%360)+360)%360
    self.xVal = e.clientX
    self.yVal = e.clientY

    self.dragMoveContext = (e) ->
      self.dragMove e

    self.canvas.addEventListener 'mousemove', self.dragMoveContext, false

  dragMove : (e) ->
    self = @

    switch self.direction
      when 0
        self.imgPx = self.imgPx+=(e.clientX-self.xVal)
        self.imgPy = self.imgPy+=(e.clientY-self.yVal)
      when 90
        self.imgPx = self.imgPx+=(e.clientY-self.yVal)
        self.imgPy = self.imgPy-=(e.clientX-self.xVal)
      when 180
        self.imgPx = self.imgPx-=(e.clientX-self.xVal)
        self.imgPy = self.imgPy-=(e.clientY-self.yVal)
      when 270
        self.imgPx = self.imgPx-=(e.clientY-self.yVal)
        self.imgPy = self.imgPy+=(e.clientX-self.xVal)

    self.drawImage()

    self.xVal = e.clientX
    self.yVal = e.clientY

  dragStop : ->
    self = @

    self.canvas.removeEventListener 'mousemove', self.dragMoveContext, false

  rotation : ->
    self = @
    self.animating = true

    clockWise = self.currentAngle < self.newAngle

    self.animation = setInterval ->
      if clockWise then self.currentAngle += 2 else self.currentAngle -= 2
      self.context.rotate((if clockWise then self.toRad else -self.toRad)*2)
      self.drawImage()
      if self.currentAngle is self.newAngle
        clearInterval self.animation
        self.animating = false
    ,1

  drawImage : ->
    self = @

    self.context.clearRect self.cnvClearPx, self.cnvClearPy, self.cnvClearW, self.cnvClearH

    if self.imgPx >= -self.cnvHalfW
      self.imgPx = -self.cnvHalfW
    else if self.imgPx <= self.cnvHalfW-self.imgW
      self.imgPx = self.cnvHalfW-self.imgW

    if self.imgPy >= -self.cnvHalfH
      self.imgPy = -self.cnvHalfH
    else if self.imgPy <= self.cnvHalfH-self.imgH
      self.imgPy = self.cnvHalfH-self.imgH

    self.context.drawImage self.picture, self.imgPx, self.imgPy, self.imgW, self.imgH

  saveImage : ->
    self = @
    console.log 'saveImage'
