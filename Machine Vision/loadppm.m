%LOADPPM	Load a PPM image
%
%	I = loadppm(filename)
%	I = loadppm(filename, n)
%
%	Returns a matrix containing the image loaded from the PPM format
%	file filename.  Handles ASCII (P3) and binary (P6) PGM file formats.
%	Result is returned as a 3 dimensional array where the last index
%	is the color plane.
%
%	If the filename has no extension, and open fails, a '.ppm' will
%	be appended.  If the file cannot be opened it returns [].
%
%	Wildcards are allowed in file names.  If multiple files match
%	a 4D image is returned where the last dimension is the number
%	of images contained.
%
%	I = loadpgm
%
%	Presents a file selection GUI from which the user can pick a file.
%	Uses the same path as previous call.
%
% SEE ALSO:	saveppm loadpgm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994
% $Header: /home/autom/pic/cvsroot/image-toolbox/loadppm.m,v 1.4 2005/10/30 03:32:08 pic Exp $
% $Log: loadppm.m,v $
% Revision 1.4  2005/10/30 03:32:08  pic
% Improve PPM parser.
%
% Revision 1.3  2005/07/03 10:59:28  pic
% Minor tidyup to status messages.
%
% Revision 1.2  2003/09/30 18:49:03  pic
% Minor bug in wildcard load.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function I = loadppm(file, nseq)
	persistent path

	if nargin == 0,
		if isempty(path) | (path == 0),
			[file,npath] = uigetfile([pwd '/*.ppm'], 'loadpgm');
		else
			[file,npath] = uigetfile([path '/*.ppm'], 'loadpgm');
												end
		if file == 0,
			return;	% cancel button pushed
		else
			path = npath;
			clear npath;
		end
		I = loadppm2(file);
	else
		if isempty(findstr(file, '.ppm'))
			file = [file '.ppm'];
		end

		slashes = findstr(file, '/');
		if isempty(slashes),
			fpath = './';
		else
			k = slashes(end);
			fpath = file(1:k);
		end

		s = dir(file);		% do a wildcard lookup

		switch length(s),
		case 0,
			error('cant find specified file');
		case 1,
			I = loadppm2([fpath s.name]);
		otherwise,
			if nargin == 1,
				for i=1:length(s),
					I(:,:,:,i) = loadppm2([fpath s(i).name]);
				end
			else
				I(:,:,:) = loadppm2([fpath s(nseq).name]);
			end
		end
	end


function RGB = loadppm2(file)
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	fid = fopen(file, 'r');
	if fid < 0,
		fid = fopen([file '.ppm'], 'r');
	end
	if fid < 0,
		fid = fopen([file '.pnm'], 'r');
	end
	if fid < 0,
		R = [];
		disp(['Couldn''t open file' file]);
		return
	end
		
	magic = fread(fid, 2, 'char');
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	cols = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	rows = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	maxval = fscanf(fid, '%d', 1);
	c = fread(fid,1,'char');

	if magic(1) == 'P',
		if magic(2) == '3',
			fprintf('%s: binary PPM file (%dx%d)\n', file, cols, rows)
			I = fscanf(fid, '%d', [cols*3 rows]);
		elseif magic(2) == '6',
			fprintf('%s: binary PPM file (%dx%d)\n', file, cols, rows)
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols*3 rows], fmt);
		else
			disp('Not a PPM file');
		end
	end
	%
	% now the matrix has interleaved columns of R, G, B
	%
	I = I';
	R = I(:,1:3:(cols*3));
	G = I(:,2:3:(cols*3));
	B = I(:,3:3:(cols*3));
	RGB(:,:,1) = R;
	RGB(:,:,2) = G;
	RGB(:,:,3) = B;
	fclose(fid);
