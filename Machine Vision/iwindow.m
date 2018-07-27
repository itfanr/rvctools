%IWINDOW	General function of a neighbourhood
%
%	w = IWINDOW(image, se, matlabfunc)
%	w = IWINDOW(image, se, matlabfunc, edge)
%
%	For every pixel in the input image it takes all neighbours for which 
%	the corresponding element in se are non-zero.  These are packed into
%	a vector (in raster order from top left) and passed to the specified
%	Matlab function.  The return value  becomes the corresponding output 
%	pixel value.
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

% $Header: /home/autom/pic/cvsroot/image-toolbox/iwindow.m,v 1.1 2002/05/26 10:50:23 pic Exp $
% $Log: iwindow.m,v $
% Revision 1.1  2002/05/26 10:50:23  pic
% Initial revision
%

