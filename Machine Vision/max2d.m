%MAX2d	Maximum of image
%
%	[r,c] = max2d(image)
%
%	Return the interpolated coordinates (r,c) of the greatest peak in image.
%
% SEE ALSO:	ihough xyhough
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1996 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/max2d.m,v 1.2 2005/10/20 11:12:13 pic Exp $
% $Log: max2d.m,v $
% Revision 1.2  2005/10/20 11:12:13  pic
% Formatting.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function [r,c] = max2d(im)

	ncols = numcols(im);
	nrows = numrows(im);

	[mx,where] = max(im);

	[mx2,where2] = max(mx);

	c = where2;
	r = where(where2);

	%[r,c,mx2]
	% now try to interpolate the peak over a 3x3 window

	% can't interpolate if against an edge
	if (c>1) & (c<ncols) & (r>1) & (r<nrows),
		dx = [
			c-1 c c+1
			c-1 c c+1
			c-1 c c+1];
		dy = [
			r-1 r-1 r-1
			r   r  r
			r+1   r+1  r+1];

		p = im(r-1:r+1,c-1:c+1);
		c = sum(sum(dx.*p)) / sum(sum(p));
		r = sum(sum(dy.*p)) / sum(sum(p));
	end
