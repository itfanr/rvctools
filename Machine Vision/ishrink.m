%ISHRINK	Image smoothing and shrinking
%
%	s = ishrink(im)
%	s = ishrink(im, sigma, N)
%
%	Smooth the image, im, using Gaussian
%	smoothing of sigma (default 1) and then subsample by a factor of
%	N (default 2) in both directions.  
%
% SEE ALSO:	ismooth
%
%	Copyright (c) Peter Corke, 2000  Machine Vision Toolbox for Matlab

% 2000 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/ishrink.m,v 1.1 2005/10/30 03:26:26 pic Exp $
% $Log: ishrink.m,v $
% Revision 1.1  2005/10/30 03:26:26  pic
% Initial checkin.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%


function ims = ishrink(im, sigma, N)
	switch nargin,
	case 2,
		N = 2;
	case 1,
		N = 2;
		sigma = 1;
	end

	m = kgauss(sigma);
	for i=1:size(im,3),
		smoothed = conv2(im(:,:,i), m, 'same');
		ims(:,:,i) = smoothed(1:N:end,1:N:end);
	end

