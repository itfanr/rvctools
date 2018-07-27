%HOUGHSHOW   Show Hough accumulator
%
%	houghshow(H)
%
% Displays the Hough accumulator as an image.
%
% SEE ALSO: ihough
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% 2005 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/houghshow.m,v 1.1 2005/10/23 11:28:50 pic Exp $
% $Log: houghshow.m,v $
% Revision 1.1  2005/10/23 11:28:50  pic
% Suite of functions of displaying and processing Hough objects.
%


function houghshow(H)

	image(H.theta, H.d, 64*H.h/max(max(H.h)));
	xlabel('theta (rad)');
	ylabel('intercept');
	colormap(gray(64))
