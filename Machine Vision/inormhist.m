%NORMHIST	Histogram normalization
%
%	n = NORMHIST(image)
%
%	Returns a histogram normalized image.  Assumes that pixels lie in the
%	range 0-255.
%
% SEE ALSO:	ihist
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/inormhist.m,v 1.1 2005/10/23 11:30:42 pic Exp $
% $Log: inormhist.m,v $
% Revision 1.1  2005/10/23 11:30:42  pic
% Histogram normalization.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function ni = normhist(im)
	h = ihist(im);
	ch = cumsum(h);
	ch = ch ./ max(ch) * 255;
	[nr,nc] = size(im);
	ii = im(:);
	ni = interp1([0:255]', ch, ii, 'nearest');
	ni = reshape(ni, nr, nc);
