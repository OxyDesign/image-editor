'use strict';
var ImageEditor;

ImageEditor = (function() {
  function ImageEditor(config) {
    var elt, self;
    if (config == null) {
      config = {};
    }
    if (!config.elt) {
      return;
    }
    self = this;
    self.config = config;
    self.formats = ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'];
    elt = self.config.elt;
    self.reader = new FileReader();
    self.input = self.config.input || elt.querySelector('input[type=file]');
    self.canvas = self.config.canvas || elt.querySelector('canvas');
    self.btLeft = self.config.btLeft || elt.querySelector('.bt-left');
    self.btRight = self.config.btRight || elt.querySelector('.bt-right');
    self.btLess = self.config.btLess || elt.querySelector('.bt-less');
    self.btMore = self.config.btMore || elt.querySelector('.bt-more');
    self.btSave = self.config.btSave || elt.querySelector('.bt-save');
    self.doc = document;
    self.context = self.canvas.getContext('2d');
    self.cnvW = self.canvas.width;
    self.cnvH = self.canvas.height;
    self.cnvRatio = self.canvas.height / self.canvas.width;
    self.cnvHalfW = self.cnvW / 2;
    self.cnvHalfH = self.cnvH / 2;
    self.cnvClearPx = -self.cnvW;
    self.cnvClearPy = -self.cnvH;
    self.cnvClearW = self.cnvW * 2;
    self.cnvClearH = self.cnvH * 2;
    self.toRad = Math.PI / 180;
    self.zoom = !self.config.zoom ? 1.1 : self.config.zoom <= 1 ? 1.1 : self.config.zoom > 2 ? 2 : self.config.zoom;
    self.maxZoom = !self.config.maxZoom ? 20 : self.config.maxZoom < 1 ? 1 : self.config.maxZoom > 25 ? 25 : self.config.maxZoom;
    self.maxSize = !self.config.maxSize ? 5 : self.config.maxSize < 1 ? 1 : self.config.maxSize > 15 ? 15 : self.config.maxSize;
    self.maxSize = self.maxSize * 1000000;
    self.reader.onload = function(p) {
      return self.update(p.target.result);
    };
    self.reader.onabort = function(p) {
      if (self.config.callbackOnAbort) {
        return self.config.callbackOnAbort(p.target.error.message);
      }
    };
    self.reader.onerror = function(p) {
      if (self.config.callbackOnError) {
        return self.config.callbackOnError(p.target.error.message);
      }
    };
    self.reader.onloadstart = function() {
      if (self.config.callbackOnLoadStart) {
        return self.config.callbackOnLoadStart();
      }
    };
    self.reader.onprogress = function(p) {
      if (self.config.callbackOnProgress) {
        return self.config.callbackOnProgress(p.loaded / p.total * 100);
      }
    };
    self.reader.onloadend = function(p) {
      if (self.config.callbackOnLoadEnd) {
        return self.config.callbackOnLoadEnd();
      }
    };
    self.input.addEventListener('change', function(e) {
      var newFile;
      if (!e.target.files[0]) {
        return;
      }
      newFile = e.target.files[0];
      if (newFile.size > self.maxSize) {
        if (self.config.callbackOnOverSize) {
          self.config.callbackOnOverSize(newFile.size, self.maxSize);
        }
        return;
      }
      return self.reader.readAsDataURL(newFile);
    });
  }

  ImageEditor.prototype.checkFormat = function(pic) {
    var format, isValid, j, len, ref, self;
    self = this;
    isValid = false;
    ref = self.formats;
    for (j = 0, len = ref.length; j < len; j++) {
      format = ref[j];
      if (~pic.indexOf(format)) {
        isValid = true;
        break;
      }
    }
    return isValid;
  };

  ImageEditor.prototype.init = function() {
    var self;
    self = this;
    self.btLeft.addEventListener('click', self.turnLeft.bind(self), false);
    self.btRight.addEventListener('click', self.turnRight.bind(self), false);
    self.btLess.addEventListener('click', self.zoomOut.bind(self), false);
    self.btMore.addEventListener('click', self.zoomIn.bind(self), false);
    self.btSave.addEventListener('click', self.saveImage.bind(self), false);
    self.canvas.addEventListener('mousedown', self.dragStart.bind(self), false);
    self.context.translate(self.cnvHalfW, self.cnvHalfH);
    self.context.save();
    self.drawImage();
    self.initialized = true;
    if (self.config.callbackOnInit) {
      return self.config.callbackOnInit();
    }
  };

  ImageEditor.prototype.update = function(pic) {
    var self;
    self = this;
    if (!self.checkFormat(pic)) {
      if (self.config.callbackOnWrongFormat) {
        self.config.callbackOnWrongFormat(pic, self.formats);
      }
      return;
    }
    self.createImg(pic);
    self.context.rotate(self.toRad * -(self.currentAngle || 0));
    self.currentAngle = 0;
    self.newAngle = 0;
    self.currentZoom = 1;
    self.imgSettings();
    if (!self.initialized) {
      self.picture.onload = function() {
        return self.init();
      };
      return;
    }
    self.context.restore();
    self.drawImage();
    if (self.config.callbackOnUpdate) {
      return self.config.callbackOnUpdate();
    }
  };

  ImageEditor.prototype.createImg = function(pic) {
    var self;
    self = this;
    self.picture = new Image();
    self.picture.setAttribute('crossOrigin', 'anonymous');
    return self.picture.src = pic;
  };

  ImageEditor.prototype.imgSettings = function() {
    var pictureLandscape, self;
    self = this;
    self.picRatio = self.picture.height / self.picture.width;
    pictureLandscape = self.picRatio < 1;
    self.imgW = pictureLandscape ? self.cnvW / self.picRatio : self.cnvW;
    self.imgH = pictureLandscape ? self.cnvH : self.cnvH * self.picRatio;
    self.imgPx = -self.imgW / 2;
    return self.imgPy = -self.imgH / 2;
  };

  ImageEditor.prototype.turnLeft = function() {
    var self;
    self = this;
    self.animation && clearInterval(self.animation);
    self.newAngle -= 90;
    self.rotation();
    if (self.config.callbackOnTurnLeft) {
      return self.config.callbackOnTurnLeft(self.newAngle);
    }
  };

  ImageEditor.prototype.turnRight = function() {
    var self;
    self = this;
    self.animation && clearInterval(self.animation);
    self.newAngle += 90;
    self.rotation();
    if (self.config.callbackOnTurnRight) {
      return self.config.callbackOnTurnRight(self.newAngle);
    }
  };

  ImageEditor.prototype.zoomOut = function() {
    var self;
    self = this;
    if (self.currentZoom <= 1) {
      return;
    }
    self.imgW /= self.zoom;
    self.imgH /= self.zoom;
    self.currentZoom--;
    self.drawImage();
    if (self.config.callbackOnZoomOut) {
      return self.config.callbackOnZoomOut(self.currentZoom);
    }
  };

  ImageEditor.prototype.zoomIn = function() {
    var self;
    self = this;
    if (self.currentZoom > self.maxZoom) {
      return;
    }
    self.imgW *= self.zoom;
    self.imgH *= self.zoom;
    self.currentZoom++;
    self.drawImage();
    if (self.config.callbackOnZoomIn) {
      return self.config.callbackOnZoomIn(self.currentZoom);
    }
  };

  ImageEditor.prototype.dragStart = function(e) {
    var self;
    self = this;
    e.preventDefault();
    self.direction = ((self.newAngle % 360) + 360) % 360;
    self.xVal = e.clientX;
    self.yVal = e.clientY;
    self.dragMoveContext = function(e) {
      return self.dragMove(e);
    };
    self.dragStopContext = function(e) {
      return self.dragStop(e);
    };
    self.canvas.addEventListener('mousemove', self.dragMoveContext, false);
    self.doc.addEventListener('mouseup', self.dragStopContext, false);
    if (self.config.callbackOnDragStart) {
      return self.config.callbackOnDragStart(self.xVal, self.yVal);
    }
  };

  ImageEditor.prototype.dragMove = function(e) {
    var self;
    self = this;
    switch (self.direction) {
      case 0:
        self.imgPx = self.imgPx += e.clientX - self.xVal;
        self.imgPy = self.imgPy += e.clientY - self.yVal;
        break;
      case 90:
        self.imgPx = self.imgPx += e.clientY - self.yVal;
        self.imgPy = self.imgPy -= e.clientX - self.xVal;
        break;
      case 180:
        self.imgPx = self.imgPx -= e.clientX - self.xVal;
        self.imgPy = self.imgPy -= e.clientY - self.yVal;
        break;
      case 270:
        self.imgPx = self.imgPx -= e.clientY - self.yVal;
        self.imgPy = self.imgPy += e.clientX - self.xVal;
    }
    self.drawImage();
    self.xVal = e.clientX;
    self.yVal = e.clientY;
    if (self.config.callbackOnDragMove) {
      return self.config.callbackOnDragMove(self.xVal, self.yVal);
    }
  };

  ImageEditor.prototype.dragStop = function() {
    var self;
    self = this;
    self.canvas.removeEventListener('mousemove', self.dragMoveContext, false);
    self.doc.removeEventListener('mouseup', self.dragStopContext, false);
    if (self.config.callbackOnDragStop) {
      return self.config.callbackOnDragStop(self.xVal, self.yVal);
    }
  };

  ImageEditor.prototype.rotation = function() {
    var clockWise, self;
    self = this;
    self.animating = true;
    clockWise = self.currentAngle < self.newAngle;
    return self.animation = setInterval(function() {
      if (clockWise) {
        self.currentAngle += 2;
      } else {
        self.currentAngle -= 2;
      }
      self.context.rotate((clockWise ? self.toRad : -self.toRad) * 2);
      self.drawImage();
      if (self.currentAngle === self.newAngle) {
        clearInterval(self.animation);
        return self.animating = false;
      }
    }, 1);
  };

  ImageEditor.prototype.dataURItoBlob = function(dataURI) {
    byteString;
    mimestring;
    var byteString, content, i, mimestring;
    if (dataURI.split(',')[0].indexOf('base64') !== -1) {
      byteString = atob(dataURI.split(',')[1]);
    } else {
      byteString = decodeURI(dataURI.split(',')[1]);
    }
    mimestring = dataURI.split(',')[0].split(':')[1].split(';')[0];
    content = new Array();
    i = 0;
    while (i < byteString.length) {
      content[i] = byteString.charCodeAt(i);
      i++;
    }
    return new Blob([new Uint8Array(content)], {
      type: 'image/jpeg'
    });
  };

  ImageEditor.prototype.drawImage = function() {
    var self;
    self = this;
    self.context.clearRect(self.cnvClearPx, self.cnvClearPy, self.cnvClearW, self.cnvClearH);
    if (self.imgPx >= -self.cnvHalfW) {
      self.imgPx = -self.cnvHalfW;
    } else if (self.imgPx <= self.cnvHalfW - self.imgW) {
      self.imgPx = self.cnvHalfW - self.imgW;
    }
    if (self.imgPy >= -self.cnvHalfH) {
      self.imgPy = -self.cnvHalfH;
    } else if (self.imgPy <= self.cnvHalfH - self.imgH) {
      self.imgPy = self.cnvHalfH - self.imgH;
    }
    return self.context.drawImage(self.picture, self.imgPx, self.imgPy, self.imgW, self.imgH);
  };

  ImageEditor.prototype.saveImage = function() {
    var imgUrl, self;
    self = this;
    if (self.animating) {
      return;
    }
    imgUrl = self.canvas.toDataURL();
    if (self.config.callbackOnSave) {
      return self.config.callbackOnSave({
        base64: imgUrl,
        blob: self.dataURItoBlob(imgUrl)
      });
    }
  };

  return ImageEditor;

})();
