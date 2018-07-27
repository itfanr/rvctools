%COLORDISTANCE Return distance in RG colorspace
%
%	cd = colordistance(rgb, rg)
%
%	The color image is converted to (r,g) coordinates and the distance
%	of each pixel from the specificed coordinage rg is computed.
%
%	The output is an image with the same number of rows and columns as
%	rgb where each pixel represents the correspoding color space distance.
%
%	This output image could be thresholded to determine color similarity.
%
% SEE ALSO:	colorseg
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab


% Peter Corke 2005
%

function s = colordistance(im, rg)

	% convert image to (r,g) coordinates
	rgb = sum(im, 3);
	r = im(:,:,1) ./ rgb;
	g = im(:,:,2) ./ rgb;

	% compute the Euclidean color space distance
	d = (r - rg(1)).^2 + (g - rg(2)).^2;

	if nargout == 0,
		idisp(d)
	else
		s = d;
	end

	


