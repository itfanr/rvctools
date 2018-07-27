%IOPEN	Morphological opening
%
%	b = iopen(im)
%	b = iopen(im, se)
%	b = iopen(im, se, n)
%
%	Return the image A after morphological opening with the structuring
%	element SE.  N (default to 1) erosions then N dilations are performed.
%
% SEE ALSO:	iclose imorph
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/iopen.m,v 1.2 2005/10/20 11:15:04 pic Exp $
% $Log: iopen.m,v $
% Revision 1.2  2005/10/20 11:15:04  pic
% Doco tidyup, default to ones(3,3) structuring element if none given.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%

function b = iopen(a, se, n)
	if nargin < 3,
		n = 1;
	end
	if nargin < 2,
		se = ones(3,3);
	end

	b = a;
	for i=1:n,
		b = imorph(b, se, 'min');
	end
	for i=1:n,
		b = imorph(b, se, 'max');
	end
