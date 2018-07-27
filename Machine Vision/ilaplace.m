%ILAPLACE	Convolve with Laplacian kernel
%
%	im2 = ilaplace(image)
%
%	Return the image after convolution with the Laplacian kernel
%		0 -1  0
%		-1 4 -1
%		0 -1  0
%
%	The resulting image is the same size as the input image.
%
% SEE ALSO:	ilog conv2
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/ilaplace.m,v 1.1 2005/10/30 03:27:20 pic Exp $
% $Log: ilaplace.m,v $
% Revision 1.1  2005/10/30 03:27:20  pic
% Laplacian filter
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function il = ilaplace(im);

	m = klaplace;
	for i=1:size(im,3),
		il(:,:,i) = conv2(im(:,:,i), m, 'same');
	end
	
