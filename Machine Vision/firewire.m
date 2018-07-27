%FIREWIRE	Read from firewire camera
%
%	h = firewire(port, color, rate)
%	im = firewire(h)
%
% First form opens the interface and returns a handle or [] on error.
% Color is one of 'mono', 'rgb' or 'yuv'.  Rate is one of the
% standard DC1394 rates: 1.875, 3.75, 7.5, 15, 30 or 60 fps.  The
% highest rate less than or equal to rate is chosen.
%
% Second form reads an image.  For mono a 2-d matrix is returned,
% for rgb a 3-d matrix is returned.  For yuv a structure is
% returned with elements .y, .u and .v.
%
%
% SEE ALSO:	webcam, idisp
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/firewire.m,v 1.1 2005/10/21 06:07:06 pic Exp $
% $Log: firewire.m,v $
% Revision 1.1  2005/10/21 06:07:06  pic
% Mex-file wrapper for reading from firewire interface using dc1394 libs
% under Linux.
%
