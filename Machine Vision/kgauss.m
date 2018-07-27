%KGAUSS	Gaussian smoothing kernel
%
%	k = kgauss(sigma)
%	k = kgauss(sigma, w)
%
%	Returns a unit volume Gaussian smoothing kernel.  The Gaussian has 
%	a standard deviation of sigma, and the convolution
%	kernel has a half size of w, that is, k is (2W+1) x (2W+1).
%
%	If w is not specified it defaults to 2*sigma.
%
% SEE ALSO:	ismooth conv2
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


%	pic 11/04
% $Header: /home/autom/pic/cvsroot/image-toolbox/kgauss.m,v 1.1 2005/10/23 12:06:52 pic Exp $
% $Log: kgauss.m,v $
% Revision 1.1  2005/10/23 12:06:52  pic
% Common kernels.
%
%


function m = kgauss(sigma, w)


	if nargin == 1,
		w = ceil(2*sigma);
	end
	ww = 2*w + 1;

	[x,y] = meshgrid(-w:w, -w:w);

	m = 1/(2*pi) * exp( -(x.^2 + y.^2)/2/sigma^2);

	m = m / sum(sum(m));

