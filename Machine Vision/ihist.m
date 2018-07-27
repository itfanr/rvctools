%IHIST	Image histogram (fast)
%
%	ihist(image)
%	h = ihist(image)
%	[h,x] = ihist(image)
%
%	Compute a greylevel histogram of IMAGE.  Much faster than the builtin
%	hist() function.  The histogram is fixed with 256 bins spanning
%	the greylevel range 0 to 255.
%
%	The first form displays the histogram, the second form returns the
%	histogram.
%
% SEE ALSO:  hist
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/ihist.m,v 1.3 2005/10/20 11:16:38 pic Exp $
% $Log: ihist.m,v $
% Revision 1.3  2005/10/20 11:16:38  pic
% Doco change.
%
% Revision 1.2  2005/07/04 03:17:46  pic
% Change graph to bar type.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%

function [h,x] = ihist(im)

	[hh,xx] = fhist(im);

	if nargout == 0,
		bar(xx, hh);
		xlabel('Greylevel')
		ylabel('Number of pixels');
	elseif nargout == 1,
		h = hh;
	elseif nargout == 2,
		h = hh;
		x = xx;
	end
