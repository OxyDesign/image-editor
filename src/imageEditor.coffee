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

    self.imgSettings()

    self.context.translate self.cnvHalfW, self.cnvHalfH
    self.drawImage()

    self.initialized = true

  update : (pic) ->
    self = @

    self.picture = new Image()
    self.picture.setAttribute 'crossOrigin', 'anonymous'
    self.picture.src = pic

    self.imgSettings()

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

    self.context.drawImage self.picture, self.imgPx, self.imgPy, self.imgW, self.imgH

  saveImage : ->
    self = @
    console.log 'saveImage'
