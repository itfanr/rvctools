%YUV2RGB	Convert YUV format to RGB
%
%	[r,g,b] = yuvread2(y, u, v)
%	rgb = yuvread(y, u, v)
%
%	Returns the equivalent RGB image from YUV components.  The UV images are
%	doubled in resolution so the resulting color image is original size.
%
%	Copyright (c) Peter Corke, 2004  Machine Vision Toolbox for Matlab


% Peter Corke 2004
% $Header: /home/autom/pic/cvsroot/image-toolbox/yuv2rgb2.m,v 1.1 2005/07/04 02:53:16 pic Exp $
% $Log: yuv2rgb2.m,v $
% Revision 1.1  2005/07/04 02:53:16  pic
% Convert YUV 422 image to half size RGB image.
%
%
function [R,G,B] = yuv2rgb2(y, u2, v2)

	% subsample, probably should smooth first...
	u = zeros(2*size(u2));
	v = zeros(2*size(v2));

	for i=1:4,
		u(1:2:end,1:2:end) = u2;
		v(1:2:end,1:2:end) = v2;

		u(2:2:end,1:2:end) = u2;
		v(2:2:end,1:2:end) = v2;

		u(1:2:end,2:2:end) = u2;
		v(1:2:end,2:2:end) = v2;

		u(2:2:end,2:2:end) = u2;
		v(2:2:end,2:2:end) = v2;
	end

	Cr = u - 128;
	Cb = v - 128;

	% convert to RGB
	r = (y + 1.366*Cr - 0.002*Cb);
	g = (y - 0.700*Cr - 0.334*Cb);
	b = (y - 0.006*Cr + 1.732*Cb);

	% clip the values into range [0, 255]
	r = max(0, min(r, 255));
	g = max(0, min(g, 255));
	b = max(0, min(b, 255));

	if nargout == 1,
		R(:,:,1) = r;
		R(:,:,2) = g;
		R(:,:,3) = b;
	else
		R = r;
		G = g;
		B = b;
	end
