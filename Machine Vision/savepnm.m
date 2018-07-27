%SAVEPNM	Write a PNM format file
%
%	SAVEPNM(filename, image)
%
%	Saves the image in a binary greyscale (P5) or color (P6)
%	format image file depending on the number of planes.
%
%	If the maximum pixel value is less than 1 assume image is
%	normalized in range 0-1, so values are scaled up to range 0-255.
%
% SEE ALSO:	loadpgm loadppm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994
% $Header: /home/autom/pic/cvsroot/image-toolbox/savepnm.m,v 1.1 2005/10/23 11:19:47 pic Exp $
% $Log: savepnm.m,v $
% Revision 1.1  2005/10/23 11:19:47  pic
% Save file in PGM or PPM format according to number of planes.
%
% Revision 1.2  2004/01/02 11:32:51  pic
% Fix bug in indexing, pixels incorrectly interleaved.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function savepnm(fname, im, comment)

	[r,c,p] = size(im);

	fid = fopen(fname, 'w');

	% if the maximum pixel value is less than 1 assume image is
	% normalized in range 0-1.
	if max(im(:)) <= 1,
		im = istretch(im, 255);
	end
	switch p,
	case 1,
		fprintf(fid, 'P5\n');
		if nargin == 3,
			fprintf(fid, '#%s\n', comment);
		end
		fprintf(fid, '%d %d\n', c, r);
		fprintf(fid, '255\n');
		im = im';
	case 3,
		fprintf(fid, 'P6\n');
		if nargin == 3,
			fprintf(fid, '#%s\n', comment);
		end
		fprintf(fid, '%d %d\n', c, r);
		fprintf(fid, '255\n');

		% rearrange the data for writing in one hit
		R = im(:,:,1);
		G = im(:,:,2);
		B = im(:,:,3);
		R = R';
		G = G';
		B = B';
		im = [R(:)'; G(:)'; B(:)'];
	otherwise,
		fclose(fid)
		error('Image must have 1 or 3 planes');
	end

	fwrite(fid, im, 'uchar');
	fclose(fid);
