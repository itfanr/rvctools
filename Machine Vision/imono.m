%IMONO	Convert color image to monochrome
%
%	im = imono(rgb)
%
% SEE ALSO:	rgb2hsv
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/imono.m,v 1.1 2005/10/23 12:08:08 pic Exp $
% $Log: imono.m,v $
% Revision 1.1  2005/10/23 12:08:08  pic
% Convert color image to greyscale.
%

function im = imono(rgb)

	hsv = rgb2hsv(rgb);
	return hsv(:,:,3);
