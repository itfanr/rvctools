%IGAMMA	Gamma correction
%
%	g = igamma(image, gamma)
%	g = igamma(image, gamma, maxval)
%
%	Return a gamma corrected version of IMAGE.  All pixels
%	are raised to the power GAMMA.
%
%	Assumes pixels are in the range 0 to maxval, default maxval = 1.
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/igamma.m,v 1.2 2005/10/20 11:15:48 pic Exp $
% $Log: igamma.m,v $
% Revision 1.2  2005/10/20 11:15:48  pic
% Handle case for pixel with arbitrary maximum value.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%

function g = igamma(im, gam, maxval)

	d = size(im,3);

	if nargin < 3,
		m = max(im(:));
		if m > 1,
			maxval = 256;
		end
	end

	for i=1:d,
		g(:,:,i) = ( (im(:,:,i) / maxval) .^ gam ) * maxval;
	end
