%IMORPH		Morphological neighbourhood processing
%
%		mi = IMORPH(image, se, op)
%		mi = IMORPH(image, se, op, edge)
%
%	Performs grey scale or binary morphology of the input image using the
%	binary structuring element se.  The operation, op, can be one of 
%	 	'min'	minimum value over the structuring element
%		'max'	maximum value over the structuring element
%		'diff'	maximum - minimum value over the structuring element
%
%	Edge handling flags control what happens when the processing window
%	extends beyond the edge of the image. 	EDGE is either
%		'border' the border value is replicated
%		'none'	 pixels beyond the border are not included in the window
%		'trim'	 output is not computed for pixels whose window crosses
%			 the border, hence output image had reduced dimensions.
%		'wrap'	 the image is assumed to wrap around
%
% SEE ALSO:  icircle
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/imorph.m,v 1.1 2002/05/26 10:50:22 pic Exp $
% $Log: imorph.m,v $
% Revision 1.1  2002/05/26 10:50:22  pic
% Initial revision
%

