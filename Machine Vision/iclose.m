%ICLOSE	Morphological closing
%
%	b = iclose(im)
%	b = iclose(im, se)
%	b = iclose(im, se, n)
%
%	Return the image im after morphological closing with the structuring
%	element se (default to ones(3,3).   n (default to 1) dilations then 
%	N erosions are performed.
%
% SEE ALSO:	iopen imorph
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/iclose.m,v 1.2 2005/10/20 11:15:04 pic Exp $
% $Log: iclose.m,v $
% Revision 1.2  2005/10/20 11:15:04  pic
% Doco tidyup, default to ones(3,3) structuring element if none given.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%


function b = iclose(a, se, n)

	if nargin < 3,
		n = 1;
	end
	if nargin < 2,
		se = ones(3,3);
	end

	b = a;
	for i=1:n,
		b = imorph(b, se, 'max');
	end
	for i=1:n,
		b = imorph(b, se, 'min');
	end
