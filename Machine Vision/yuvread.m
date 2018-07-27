%YUVREAD	Read frame from a YUV4MPEG file
%
%	[y,u,v] = yuvread(yuv, skip)
%	[y,u,v, h] = yuvread(yuv, skip)
%
%	Returns the Y, U and V components from the specified frame of
%	YUV file.  Optionally returns the frame header h.
%
% SEE ALSO:	yuvopen yuv2rgb yuv2rgb2
%
%	Copyright (c) Peter Corke, 2004  Machine Vision Toolbox for Matlab


% Peter Corke 2004
% $Header: /home/autom/pic/cvsroot/image-toolbox/yuvread.m,v 1.2 2005/10/23 12:06:06 pic Exp $
% $Log: yuvread.m,v $
% Revision 1.2  2005/10/23 12:06:06  pic
% Doco update.
%
%

function [Y,U,V, h] = yuvread(yuv, skip)


	if nargin == 1,
		skip = 0;
	end

	while skip >= 0,
		% read and display the header
		hdr = fgets(yuv.fp);
		fprintf('header: %s', hdr);


		% read the YUV data
		[Y,count] = fread(yuv.fp, yuv.w*yuv.h, 'uchar');
		if count ~= yuv.w*yuv.h,
			Y = [];
			return;
		end
		[V,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
		if count ~= yuv.w*yuv.h/4,
			Y = [];
			return;
		end
		[U,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
		if count ~= yuv.w*yuv.h/4,
			Y = [];
			return;
		end

		skip = skip - 1;
	end

	Y = reshape(Y, yuv.w, yuv.h)';
	U = reshape(U, yuv.w/2, yuv.h/2)';
	V = reshape(V, yuv.w/2, yuv.h/2)';

	if nargin == 4,
		h = hdr;
	end
