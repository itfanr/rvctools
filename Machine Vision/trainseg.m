%TRAINSEG	Interactively train a color segmentation
%
%	map = trainseg(im)
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
% SEE ALSO: colorseg imorph
%

%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab
% Peter Corke 2005
% $Header: /home/autom/pic/cvsroot/image-toolbox/trainseg.m,v 1.1 2005/10/23 11:28:24 pic Exp $
% $Log: trainseg.m,v $
% Revision 1.1  2005/10/23 11:28:24  pic
% Suite of functions to perform color segmentation.
%
function map = colorseg(im)

	% convert image to (r,g) coordinates
	y = sum(im, 3);
	r = round( im(:,:,1) ./ y * 255);
	g = round( im(:,:,2) ./ y * 255);

	% display the original image

	% create and display the map
	map = zeros(256, 256);
	hm = figure
	set(gcf, 'Units', 'normalized', 'Position', [0.1 0.5 0.8 0.4])
	subplot(121)
	image(im)
	axis('equal')
	title('input image')

	subplot(122)
	image(map)
	axis('equal')
	xlabel('r');
	ylabel('g');
	colormap(gray(2));
	title('segmentation map')

	while 1,
		subplot(121)
		[y,x] = ginput(1);
		if isempty(y),
			break;
		end
		x = round(x);
		y = round(y);
		map(r(x,y), g(x,y)) = 256;
		subplot(122)
		image(map)
		drawnow
	end

	map = map';
