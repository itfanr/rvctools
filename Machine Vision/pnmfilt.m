%PNMFILT	Pipe image through PNM utility
%
%	f = pnmfilt(im, cmd)
%
%	Pipe image through a Unix filter program.  Input and output image 
%	formats	are PNM.
%
% SEE ALSO: xv savepnm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% 1996 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/pnmfilt.m,v 1.1 2005/10/23 11:29:54 pic Exp $
% $Log: pnmfilt.m,v $
% Revision 1.1  2005/10/23 11:29:54  pic
% Filter image via external pnm utility.
%
% Revision 1.2  2005/07/04 03:17:04  pic
% Use imread() instead of loadpgm().
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function im2 = pnmfilt(im, cmd)

	% MATLAB doesn't support pipes, so it all has to be done via 
	% temp files :-(

	% make up two file names
	ifile = sprintf('%s.pnm', tempname);
	ofile = sprintf('%s.pnm', tempname);

	savepnm(ifile, im);
	%cmd
	unix([cmd ' < ' ifile ' > ' ofile]);

	im2 = double( imread(ofile) );
	unix(['/bin/rm ' ifile ' ' ofile]);
