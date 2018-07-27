%ZCROSS		Zero-crossing detector
%
%	IZ = ZCROSS(image)
%
%	Crude zero-crossing detector.  Returns a binary image in which set (1)
%	pixels correspond to negative input pixels adjacent to a transition to
%	transition to a non-negative value.
%
% SEE ALSO:	ilog
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% 1997 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/zcross.m,v 1.1 2002/05/26 10:50:25 pic Exp $
% $Log: zcross.m,v $
% Revision 1.1  2002/05/26 10:50:25  pic
% Initial revision
%


function iz = zcross(im)

	w = numcols(im);
	h = numrows(im);

	% horizontal transitions
	ineg = im(:,1:w-1) < 0;
	ipos = im(:,2:w) >= 0;

	iz = [ineg&ipos zeros(h,1)];

	% vertical transitions
	ineg = im(1:h-1,:) < 0;
	ipos = im(2:h,:) >= 0;

	% return if either happened at this pixel
	iz = iz | [ineg&ipos; zeros(1,w)];
