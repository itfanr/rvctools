%WEBCAM  Load frame from webcam.
%
%  im = webcam(url);
%
%  Load image from the specified URL.
%
% Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/webcam.m,v 1.1 2005/10/23 12:07:45 pic Exp $
% $Log: webcam.m,v $
% Revision 1.1  2005/10/23 12:07:45  pic
% Read image from URL.
%

function imout = webcam(url);

	im = imread(url);

	[nr,nc] = size(im);
	im = im(nr:-1:1,:,:);

	if nargout == 0,
		image(im);
	else
		imout = im;
	end
