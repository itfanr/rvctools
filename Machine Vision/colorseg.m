%COLORSEG	Segment a color image.
%
%	seg = colorseg(im, map)
%
%	Two windows are displayed, one the bivariant histogram in
%	normalized (r,g) coordinates, the other the original image.
%
%	For each pixel selected and clicked in the original image a point
%	is marked in the bivariant histogram.  By selecting numerous points
%	in the color region of interest, its extent in the (r,g) plane 
%	develops.
%
%	This map can be smoothed, expanded and filled in using morphological
%	operations.
%
% SEE ALSO: trainseg
%

%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab
% Peter Corke 2005
% $Header: /home/autom/pic/cvsroot/image-toolbox/colorseg.m,v 1.1 2005/10/23 11:28:24 pic Exp $
% $Log: colorseg.m,v $
% Revision 1.1  2005/10/23 11:28:24  pic
% Suite of functions to perform color segmentation.
%
function out = colorseg(im, map)

	% convert the image to (r,g) coordinates
	y = sum(im, 3);
	r = round( im(:,:,1) ./ y * 255);
	g = round( im(:,:,2) ./ y * 255);

	% convert the (r,g) pixel values to 1D coordinates in the lookup
	% table.
	k = sub2ind(size(map), g(:)+1, r(:)+1);

	% apply the map
	out = map(k);
	out = reshape(out, size(im(:,:,1)));

