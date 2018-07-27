%YUV2RGB	Convert YUV format to RGB
%
%	[r,g,b] = yuvread(y, u, v)
%	rgb = yuvread(y, u, v)
%
%	Returns the equivalent RGB image from YUV components.  The Y image is
%	halved in resolution.
%
%	Copyright (c) Peter Corke, 2004  Machine Vision Toolbox for Matlab


% Peter Corke 2004
% $Header: /home/autom/pic/cvsroot/image-toolbox/yuv2rgb.m,v 1.1 2005/07/04 02:54:16 pic Exp $
% $Log: yuv2rgb.m,v $
% Revision 1.1  2005/07/04 02:54:16  pic
% Initial version of yuv4mpeg support.
%
%
function [R,G,B] = yuv2rgb(y, u, v)

	% subsample, probably should smooth first...
	y = y(1:2:end, 1:2:end);

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
