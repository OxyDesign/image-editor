'use strict'

class ImageEditor
  constructor: (config={}) ->
    return if not (config.elt or config.pic)

    self = @

    self.config = config
    self.formats = ['image/jpg','image/jpeg','image/png','image/gif']

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
    self.toRad = Math.PI/180
    self.zoom = 1.1
    self.maxZoom = 20

    self.update self.config.pic

  checkFormat : (pic) ->
    self = @

    isValid = false

    for format in self.formats
      if ~pic.indexOf format
        isValid = true
        break

    return isValid

  init : ->
    self = @

    self.btLeft.addEventListener 'click', self.turnLeft.bind(self), false
    self.btRight.addEventListener 'click', self.turnRight.bind(self), false
    self.btLess.addEventListener 'click', self.zoomOut.bind(self), false
    self.btMore.addEventListener 'click', self.zoomIn.bind(self), false
    self.btSave.addEventListener 'click', self.saveImage.bind(self), false

    self.canvas.addEventListener 'mousedown', self.dragStart.bind(self), false

    self.context.translate self.cnvHalfW, self.cnvHalfH
    self.context.save()
    self.drawImage()

    self.initialized = true

    self.config.callbackOnInit() if self.config.callbackOnInit

  update : (pic) ->
    self = @

    return if !self.checkFormat pic

    self.createImg pic

    self.context.rotate self.toRad*-(self.currentAngle || 0)

    self.currentAngle = 0
    self.newAngle = 0
    self.currentZoom = 1

    self.imgSettings()

    if !self.initialized
      self.picture.onload = ->
        self.init()
      return

    self.context.restore()
    self.drawImage()

    self.config.callbackOnUpdate() if self.config.callbackOnUpdate

  createImg : (pic) ->
    self = @

    self.picture = new Image()
    self.picture.setAttribute 'crossOrigin', 'anonymous'
    self.picture.src = pic

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

    self.config.callbackOnTurnLeft self.newAngle  if self.config.callbackOnTurnLeft

  turnRight : ->
    self = @
    self.animation and clearInterval self.animation
    self.newAngle += 90
    self.rotation()

    self.config.callbackOnTurnRight self.newAngle  if self.config.callbackOnTurnRight

  zoomOut : ->
    self = @
    return if self.currentZoom <= 1
    self.imgW /= self.zoom
    self.imgH /= self.zoom
    self.currentZoom--
    self.drawImage()

    self.config.callbackOnZoomOut self.currentZoom if self.config.callbackOnZoomOut

  zoomIn : ->
    self = @
    return if self.currentZoom > self.maxZoom
    self.imgW *= self.zoom
    self.imgH *= self.zoom
    self.currentZoom++
    self.drawImage()

    self.config.callbackOnZoomIn self.currentZoom if self.config.callbackOnZoomIn

  dragStart : (e) ->
    self = @
    e.preventDefault()

    self.direction = ((self.newAngle%360)+360)%360
    self.xVal = e.clientX
    self.yVal = e.clientY

    self.dragMoveContext = (e) ->
      self.dragMove e

    self.dragStopContext = (e) ->
      self.dragStop e

    self.canvas.addEventListener 'mousemove', self.dragMoveContext, false
    self.doc.addEventListener 'mouseup', self.dragStopContext, false

    self.config.callbackOnDragStart self.xVal,self.yVal if self.config.callbackOnDragStart

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

    self.config.callbackOnDragMove self.xVal,self.yVal if self.config.callbackOnDragMove

  dragStop : ->
    self = @

    self.canvas.removeEventListener 'mousemove', self.dragMoveContext, false
    self.doc.removeEventListener 'mouseup', self.dragStopContext, false

    self.config.callbackOnDragStop self.xVal,self.yVal if self.config.callbackOnDragStop

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

  dataURItoBlob:(dataURI) ->
    byteString
    mimestring

    if (dataURI.split(',')[0].indexOf('base64') != -1 )
      byteString = atob(dataURI.split(',')[1])
    else
      byteString = decodeURI(dataURI.split(',')[1])

    mimestring = dataURI.split(',')[0].split(':')[1].split(';')[0]

    content = new Array()
    i = 0
    while i < byteString.length
      content[i] = byteString.charCodeAt(i)
      i++
    return new Blob( [ new Uint8Array(content) ], { type: 'image/jpeg' } )

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
    return if self.animating
    imgUrl = self.canvas.toDataURL()

    self.config.callbackOnSave {base64 : imgUrl, blob : self.dataURItoBlob imgUrl} if self.config.callbackOnSave
