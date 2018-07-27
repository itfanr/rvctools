%KDGAUSS	Derivative of Gaussian kernel
%
%	k = kdgauss(sigma)
%	k = kdgauss(sigma, w)
%
%	Returns a kernel a x-derivative of Gaussian, this is a convolution
%	of a Gaussian smoothing kernel with a [-1 1] kernel.
%	The Gaussian has a standard deviation of sigma, and the convolution
%	kernel has a half size of w, that is, k is (2W+1) x (2W+1).
%
%	If w is not specified it defaults to 2*sigma.
%
% SEE ALSO:	kgauss kdog conv2
%
%	Copyright (c) Peter Corke, 2004  Machine Vision Toolbox for Matlab


%	pic 11/04
% $Header: /home/autom/pic/cvsroot/image-toolbox/kdgauss.m,v 1.1 2005/10/23 12:06:52 pic Exp $
% $Log: kdgauss.m,v $
% Revision 1.1  2005/10/23 12:06:52  pic
% Common kernels.
%
%


function m = kdgauss(sigma, w)


	if nargin == 1,
		w = ceil(2*sigma);
	end
	ww = 2*w + 1;

	[x,y] = meshgrid(-w:w, -w:w);

	m = -x/sigma^2 /(2*pi) .*  exp( -(x.^2 + y.^2)/2/sigma^2);
