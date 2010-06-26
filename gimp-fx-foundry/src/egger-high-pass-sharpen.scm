;
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; Highpass Filter Sharpening, V2.0 for GIMP 2.4
; Original author: Martin Egger (martin.egger@gmx.net)
; (C) 2005, Bern, Switzerland
;
; Tags: photo, sharpen
;
; Author statement:
;
; You can find more about Highpass Filter Sharpening at
; http://www.gimp.org/tutorials/Sketch_Effect/ and at
; http://www.retouchpro.com/forums/showthread.php?s=&threadid=3844&highlight=high+pass
;
; --------------------------------------------------------------------
; Distributed by Gimp FX Foundry project
; --------------------------------------------------------------------
;   - Changelog -
;
; --------------------------------------------------------------------
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;.

; Define the function
;
(define (script-fu-Eg-HighPassSharpen InImage InLayer InBlur InOpacity InFlatten)
;
; Save history			
;
	(gimp-image-undo-group-start InImage)
;
	(let*	(
		(Temp1Layer (car (gimp-layer-copy InLayer TRUE)))
		(Temp2Layer (car (gimp-layer-copy InLayer TRUE)))
		)
;
		(gimp-image-add-layer InImage Temp1Layer -1)
		(gimp-image-add-layer InImage Temp2Layer -1)
;
		(plug-in-gauss TRUE InImage Temp2Layer InBlur InBlur TRUE)
		(gimp-invert Temp2Layer)
		(gimp-layer-set-opacity Temp2Layer 50)
;
		(let*	(
			(SharpenLayer (car (gimp-image-merge-down InImage Temp2Layer CLIP-TO-IMAGE)))
			)
;
			(gimp-levels SharpenLayer HISTOGRAM-VALUE 100 150 1.0 0 255)
			(gimp-layer-set-mode SharpenLayer OVERLAY-MODE)
			(gimp-layer-set-opacity SharpenLayer InOpacity)
;
; Flatten the image, if we need to
;
			(cond
				((= InFlatten TRUE) (gimp-image-merge-down InImage SharpenLayer CLIP-TO-IMAGE))
				((= InFlatten FALSE) 
					(begin
						(gimp-drawable-set-name SharpenLayer _"Sharpened")
						(gimp-image-set-active-layer InImage InLayer)
					)
				)
			)
		)
	)
;
; Finish work
;
	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
)
;
(script-fu-register 
	"script-fu-Eg-HighPassSharpen"
	_"Sharpen (_HighPassFilter)"
	_"Eg High-Pass Filter Sharpen"
	"Martin Egger (martin.egger@gmx.net)"
	"Martin Egger, Bern, Switzerland"
	"07.10.2007"
	"RGB* GRAY*"
	SF-IMAGE	"The Image"	0
	SF-DRAWABLE	"The Layer"	0
	SF-ADJUSTMENT	_"Blur Radius"	'(7.0 1.0 80.0 1.0 0 2 0)
	SF-ADJUSTMENT	_"Sharpening Layer Opacity" '(55.0 1.0 100.0 1.0 0 2 0)
	SF-TOGGLE	_"Flatten Image"	FALSE
)
;
(script-fu-menu-register "script-fu-Eg-HighPassSharpen"
			 "<Image>/Filters/Eg")
;
