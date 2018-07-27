%ISTRETCH	Image linear normalization
%
%	g = istretch(image)
%	g = istretch(image, newmax)
%
%	Return a normalized image in which all pixels lie in the range
%	0 to 1, or 0 to newmax.
%
%

%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab
% $Header: /home/autom/pic/cvsroot/image-toolbox/istretch.m,v 1.2 2005/10/23 11:17:18 pic Exp $
% $Log: istretch.m,v $
% Revision 1.2  2005/10/23 11:17:18  pic
% Handle multi-dimensional images.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%

function zs = istretch(z, newmax)

	if nargin == 1,
		newmax = 1;
	end

	mn = min(z(:));
	mx = max(z(:));

	zs = (z-mn)/(mx-mn)*newmax;
