%XV	Display image using XV utility
%
%	xv(im)
%
%	Pipe image to the XV display utility
%
% SEE ALSO: idisp pnmfilt
%           XV is available from ftp://ftp.cis.upenn.edu/pub/xv
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1996 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/xv.m,v 1.3 2005/10/20 11:18:41 pic Exp $
% $Log: xv.m,v $
% Revision 1.3  2005/10/20 11:18:41  pic
% Doco change.
%
% Revision 1.2  2004/01/02 11:32:11  pic
% Work with color images.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%


function xv(m)
	fname = tempname;

	if length(size(m)) == 3,
		saveppm(fname, m);
	else
		savepgm(fname, m);
	end
	cmd = sprintf('(xv %s; /bin/rm %s) &', fname, fname);
	unix(cmd);
