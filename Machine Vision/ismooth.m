%ISMOOTH	Smooth with Gaussian kernel
%
%	ims = ismooth(im, sigma)
%
%	Smooths all planes of the input image im with a unit volume Gaussian 
%	function of standard deviation sigma.
%
%	The resulting image is the same size as the input image.
%
% SEE ALSO:	kgauss
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


%	pic 3/02
% $Header: /home/autom/pic/cvsroot/image-toolbox/ismooth.m,v 1.2 2005/10/20 11:14:06 pic Exp $
% $Log: ismooth.m,v $
% Revision 1.2  2005/10/20 11:14:06  pic
% Chnage args, track other chamges, tidy up.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function ims = ismooth(im, sigma)

	m = kgauss(sigma);

	for i=1:size(im,3),
		ims(:,:,i) = conv2(im(:,:,i), m, 'same');
	end
