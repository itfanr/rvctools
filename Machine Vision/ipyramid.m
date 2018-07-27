%IPYRAMID	Pyramidal image decomposition
%
%	p = ipyramid(im)
%	p = ipyramid(im, sigma)
%	p = ipyramid(im, sigma, N)
%
%	Compute pyramid decomposition of input image, IM, using Gaussian
%	smoothing of sigma (default 1) prior to each decimation.
%
%	If N is specified compute only that number of steps, otherwise the
%	pyramid is computed down to a non-halvable image size.
%
%	Result is a cell array 
%
% SEE ALSO:	kgauss ishrink
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% 1995 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/ipyramid.m,v 1.1 2005/10/30 03:27:05 pic Exp $
% $Log: ipyramid.m,v $
% Revision 1.1  2005/10/30 03:27:05  pic
% Pyramid decomposition.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function p = ipyramid(im, sigma, N)
	if nargin < 2,
		sigma = 1;
		N = floor( log2( min(size(im) ) ) );
	elseif nargin < 3,
		N = floor(log2(min(size(im))));
	end

	[height,width] = size(im);
	K = kgauss(sigma);

	p{1} = im;

	for k = 1:N,
		[nrows,ncols] = size(im);

		% smooth
		im = conv2(im, K, 'same');

		% sub sample
		im = im(1:2:nrows,1:2:ncols);

		% stash it
		p{k+1} = im;
	end
