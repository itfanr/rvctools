%KDOG	Difference of Gaussian kernel
%
%	k = kdog(sigma1, sigma2)
%	k = kdog(sigma1, sigma2, w)
%
%	Returns a difference of Gaussian kernel which can be used for
%	edge detection.
%	The Gaussians have standard deviation of sigma1 and sigma2 
%	respectively, and the convolution kernel has a half size of w, 
%	that is, k is (2W+1) x (2W+1).
%
%	If w is not specified it defaults to 2*sigma.
%
% SEE ALSO:	kgauss conv2
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab


%	pic 2/05
% $Header: /home/autom/pic/cvsroot/image-toolbox/kdog.m,v 1.1 2005/10/23 12:06:52 pic Exp $
% $Log: kdog.m,v $
% Revision 1.1  2005/10/23 12:06:52  pic
% Common kernels.
%
%


function m = kdog(sigma1, sigma2, w)


	if nargin < 3,
		w = ceil(2*max(sigma1, sigma2));
	end
	ww = 2*w + 1;

	[x,y] = meshgrid(-w:w, -w:w);

	m1 = 1/(2*pi) * exp( -(x.^2 + y.^2)/2/sigma1^2);
	m2 = 1/(2*pi) * exp( -(x.^2 + y.^2)/2/sigma2^2);

	m = m1 - m2;

