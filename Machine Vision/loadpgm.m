%LOADPGM	Load a PGM image
%
%	I = loadpgm(filename)
%
%	Returns a matrix containing the image loaded from the PGM format
%	file filename.  Handles ASCII (P2) and binary (P5) PGM file formats.
%
%	If the filename has no extension, and open fails, a '.pgm' will
%	be appended.  If the file cannot be opened it returns [].
%
%	Wildcards are allowed in file names.  If multiple files match
%	a 3D image is returned where the last dimension is the number
%	of images contained.
%
%	I = loadpgm
%
%	Presents a file selection GUI from which the user can pick a file.
%	Uses the same path as previous call.
%
%	Second return argument is the image creation time that comes
% from a TIMESPEC header comment (local convention).
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994
% $Header: /home/autom/pic/cvsroot/image-toolbox/loadpgm.m,v 1.5 2005/10/30 03:15:22 pic Exp $
% $Log: loadpgm.m,v $
% Revision 1.5  2005/10/30 03:15:22  pic
% Tidy up in PGM parser.
%
% Revision 1.4  2004/12/03 07:44:55  pic
% Return PGM image timestamp.
%
% Revision 1.3  2002/09/08 08:00:17  pic
% Added support for TIMESPEC comments (local group standard)
%
% Revision 1.2  2002/08/28 04:12:17  pic
% Added support for 16 bit PGM images.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function [I,t] = loadpgm(file)
	persistent path

	if nargin == 0,
		% invoke file browser GUI

		if isempty(path) | (path == 0),
			[file,npath] = uigetfile([pwd '/*.pgm'], 'loadpgm');
		else
			[file,npath] = uigetfile([path '/*.pgm'], 'loadpgm');
												end
		if file == 0,
			return;	% cancel button pushed
		else
			% save the path away for next time
			path = npath;
			clear npath;
		end
		[I,t] = loadpgm2([path '/' file]);
	else
		if isempty(findstr(file, '.pgm'))
			file = [file '.pgm'];
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
			 %cant do directory lookup, maybe it is a filename
			[I,t] = loadpgm2(file);
		case 1,
			[I,t] = loadpgm2([fpath s.name]);
		otherwise,
			for i=1:length(s),
				I(:,:,i) = loadpgm2([fpath s(i).name]);
			end
		end
	end

function [I,t] = loadpgm2(filename)
	filename
	t = [];
	fid = fopen(filename, 'r');
	if fid < 0,
		fid = fopen([filename '.pgm'], 'r');
	end
	if fid < 0,
		I = [];
		error(['Couldn''t open file ' filename]);
	end
		
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	% read the PX header
	magic = fread(fid, 2, 'char');

	%  read cols and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			comment = fgetl(fid);
			time = sscanf(comment, ' TIMESPEC %d %d');
			if length(time) == 2,
				t = time(1) + time(2)*1e-9;
			end
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	cols = fscanf(fid, '%d', 1);

	%  read rows and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	rows = fscanf(fid, '%d', 1);

	%  read maxval and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	maxval = fscanf(fid, '%d', 1);

	% read the newline
	c = fread(fid,1,'*char');

	% Process the header info and read the image
	if magic(1) == 'P',
		if magic(2) == '2',
			fprintf('%s: ASCII PGM file (%d x %d)\n', filename, rows, cols)
			I = fscanf(fid, '%d', [cols rows])';
		elseif magic(2) == '5',
			fprintf('%s: binary PGM file (%d x %d)\n', filename, rows, cols)
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^16-1,
				fmt = 'uint16';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols rows], fmt)';
		else
			disp('Not a PGM file');
		end
	end
	fclose(fid);
