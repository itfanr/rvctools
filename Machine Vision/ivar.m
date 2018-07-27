%IVAR	Fast neighbourhood variance/kurtosis/skewness 
%
%	V = IVAR(IM, SE, OP)
%	V = IVAR(IM, SE, OP, EDGE)
%
%	Computes the specified statistic over the pixel neighbourhood
%	which becomes the corresponding output pixel value.
%		OP is 'var', 'kurt', 'skew'
%
%	Edge handling flags control what happens when the processing window
%	extends beyond the edge of the image. 	EDGE is either
%		'border' the border value is replicated
%		'none'	 pixels beyond the border are not included in the window
%		'trim'	 output is not computed for pixels whose window crosses
%			 the border, hence output image had reduced dimensions.
%		'wrap'	 the image is assumed to wrap around
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%		pic 4/95
% $Header: /home/autom/pic/cvsroot/image-toolbox/ivar.m,v 1.1 2002/05/26 10:50:23 pic Exp $
% $Log: ivar.m,v $
% Revision 1.1  2002/05/26 10:50:23  pic
% Initial revision
%

