# image-editor


## Usage


Scale, Rotate, Crop and Process image with Canvas


## Implementation


### Load the script


```
<script src="[Path to scripts]/imageEditor.min.js"></script>
```

### Instantiation


```
var imageEditorInstance = new ImageEditor({
  elt: (DOM Element),
  ... optional settings ...
});
```

## Options (Object)


### elt

* *Container of the input file, canvas and button*
* Mandatory
* Type : `DOM Element`


### input
* *Input File Element*
* Optional
* Default value : `elt.querySelector('input[type=file]')`
* Type : `DOM Element`


### canvas
* *Canvas Element*
* Optional
* Default value : `elt.querySelector('canvas')`
* Type : `DOM Element`


### btLeft
* *Button Element to Turn Counterclockwise*
* Optional
* Default value : `elt.querySelector('.bt-left')`
* Type : `DOM Element`


### btRight
* *Button Element to Turn Clockwise*
* Optional
* Default value : `elt.querySelector('.bt-right')`
* Type : `DOM Element`


### btLess
* *Button Element to Zoom Out*
* Optional
* Default value : `elt.querySelector('.bt-less')`
* Type : `DOM Element`


### btMore
* *Button Element to Zoom In*
* Optional
* Default value : `elt.querySelector('.bt-more')`
* Type : `DOM Element`


### btSave
* *Button Element to Save the Image*
* Optional
* Default value : `elt.querySelector('.bt-save')`
* Type : `DOM Element`


### zoom
* *Zoom Ratio (Between 1.1 and 2)*
* Optional
* Default value : `1.1`
* Type : `Number`


### maxZoom
* *Max Zoom Level (Between 1 and 25)*
* Optional
* Default value : `20`
* Type : `Number`


### maxSize
* *Max File Size (in Mo)*
* Optional
* Default value : `5`
* Type : `Number`


### callbackOnInit

* *Function invoked when the editor is initalized*
* Optional
* Default value : `undefined`
* Type : `Function`
* No argument


### callbackOnUpdate

* *Function invoked when the image is updated*
* Optional
* Default value : `undefined`
* Type : `Function`
* No argument


### callbackOnTurnLeft

* *Function invoked when the image is rotated (counterclockwise)*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *New Angle in degrees* (`Number`)


### callbackOnTurnRight

* *Function invoked when the image is rotated (clockwise)*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *New Angle in degrees* (`Number`)


### callbackOnZoomOut

* *Function invoked when the image is zoomed out*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *New Zoom Level* (`Number`)


### callbackOnZoomIn

* *Function invoked when the image is zoomed in*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *New Zoom Level* (`Number`)


### callbackOnDragStart

* *Function invoked when the drag begins*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Position on X in px* (`Number`), **[1]** *Position on Y in px* (`Number`)


### callbackOnDragMove

* *Function invoked while dragging*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Position on X in px* (`Number`), **[1]** *Position on Y in px* (`Number`)


### callbackOnDragStop

* *Function invoked when the drag stops*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Position on X in px* (`Number`), **[1]** *Position on Y in px* (`Number`)


### callbackOnSave

* *Function invoked when save method is called*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** `Object` with properties **base64** that contains the 64-encoded data URI (`String`) and **blob** that contains the Blob file (`Blob`)


### callbackOnAbort

* *Function invoked when the File reading is aborted*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Error Message* (`String`)


### callbackOnError

* *Function invoked when an error occured during the File reading*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Error Message* (`String`)


### callbackOnLoadStart

* *Function invoked when the FileReader starts loading the file*
* Optional
* Default value : `undefined`
* Type : `Function`
* No argument


### callbackOnProgress

* *Function invoked while the FileReader is loading the file*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *Percentage Loaded* (`Number`)


### callbackOnLoadEnd

* *Function invoked when the FileReader ends loading the file*
* Optional
* Default value : `undefined`
* Type : `Function`
* No argument


### callbackOnOverSize

* *Function invoked when the file loaded is bigger than maxSize*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *File size (in octets)* (`Number`), **[1]** *Max size (in octets)* (`Number`)


### callbackOnWrongFormat

* *Function invoked when the file loaded is not an image*
* Optional
* Default value : `undefined`
* Type : `Function`
* Arguments : **[0]** *File (64-encoded data URI)* (`String`), **[1]** *Allowed formats* (`Array`)

