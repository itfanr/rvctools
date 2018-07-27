%IRANK	Fast neighbourhood rank filter
%
%	ri = IRANK(image, order, se)
%	ri = IRANK(image, order, se, nbins)
%	ri = IRANK(image, order, se, nbins, edge)
%
%	Performs a rank filter over the neighbourhood specified by SE.  
%	The ORDER'th value in rank becomes the corresponding output pixel value.
%	A histogram method is used with NBINS (default 256).
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

% $Header: /home/autom/pic/cvsroot/image-toolbox/irank.m,v 1.1 2002/05/26 10:50:22 pic Exp $
% $Log: irank.m,v $
% Revision 1.1  2002/05/26 10:50:22  pic
% Initial revision
%

