%MKCUBE2	Create edges of a cube
%
%	xyz = MKCUBE2
%	xyz = MKCUBE2(s)
%	xyz = MKCUBE2(s, c)
%
%	Return a 6-column matrix where each row represents the edge of
%	a cube.  Each row comprises the (x,y,z) coordinates of the start
%	and end of each edge.
%	The side length S defaults to 1.  The centre C = (x,y,z) defaults 
%	to (0,0,0).
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/mkcube2.m,v 1.2 2005/10/20 11:29:34 pic Exp $
% $Log: mkcube2.m,v $
% Revision 1.2  2005/10/20 11:29:34  pic
% Doco tidyup.
%
% Revision 1.1.1.1  2002/05/26 10:50:23  pic
% initial import
%


function xyz = mkcube2(s, c)
	if nargin == 0,
		s = 1;
		c = [0 0 0];
	elseif nargin == 1,
		c = [0 0 0];
	end

	% cube has 12 edges
	cube = [
		0 0 0 1 0 0
		0 0 0 0 1 0
		0 0 0 0 0 1

		1 1 1 0 1 1
		1 1 1 1 0 1
		1 1 1 1 1 0

		0 0 1 0 1 1
		0 0 1 1 0 1

		1 0 0 1 0 1
		1 0 0 1 1 0

		0 1 0 0 1 1
		0 1 0 1 1 0
	];

	cube = cube * s;
	cube = cube - ones(length(cube),1) * [c+s/2 c+s/2];
 
	xyz = cube;
