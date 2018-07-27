%YUVOPEN	Open a YUV4MPEG file
%
%	yuv = yuvopen(frame)
%
%	Open a yuv4mpeg format file.  This contains uncompressed color
%	images in 4:2:0 format, with a full resolution luminance plane
%	followed by U and V planes at half resolution both directions.
%
% SEE ALSO:	yuvread yuvclose
%
%	Copyright (c) Peter Corke, 2004  Machine Vision Toolbox for Matlab


% Peter Corke 2004
% $Header: /home/autom/pic/cvsroot/image-toolbox/yuvopen.m,v 1.2 2005/10/23 12:06:06 pic Exp $
% $Log: yuvopen.m,v $
% Revision 1.2  2005/10/23 12:06:06  pic
% Doco update.
%
%

function yuv = yuvopen(filename)

	yuv.fp = fopen(filename, 'r');

	hdr = fgets(yuv.fp);

	yuv.hdr = hdr;
	while length(hdr) > 1,
		[s, hdr] = strtok(hdr);
		switch s(1),
		case {'Y'}
			if strcmp(s, 'YUV4MPEG2') == 0,
				fclose(yuv.fp);
				error('not a YUV4MPEG stream');
			end
		case {'W'}
			yuv.w = str2num(s(2:end));
		case {'H'}
			yuv.h = str2num(s(2:end));
		otherwise
			fprintf('found <%s>\n', s);
		end
	end
