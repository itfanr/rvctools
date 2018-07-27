%MKCUBE		Create vertices of a cube
%
%	xyz = MKCUBE
%	xyz = MKCUBE(s)
%	xyz = MKCUBE(s, c)
%
%	[x,y,z] = MKCUBE
%	[x,y,z] = MKCUBE(s)
%	[x,y,z] = MKCUBE(s, c)
%
%	Return a 3-column matrix where each row contains the (x,y,z) coordinates
%	of a cubes vertices.  The side length S defaults to 1.  The centre
%	C = (x,y,z) defaults to (0,0,0).
%
%	Alternatively the function can be called with 3 output arguments
%	which are vectors of X, Y an Z coordinates.
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/mkcube.m,v 1.1 2002/05/26 10:50:23 pic Exp $
% $Log: mkcube.m,v $
% Revision 1.1  2002/05/26 10:50:23  pic
% Initial revision
%


function [o1,o2,o3] = mkcube(s, c)
	if nargin == 0,
		s = 1;
		c = [0 0 0];
	elseif nargin == 1,
		c = [0 0 0];
	end

	cube = [
		0 0 0
		1 0 0
		1 1 0
		0 1 0
		0 0 0
		0 0 1
		1 0 1
		1 1 1
		0 1 1
		0 0 1
		1 0 1
		1 0 0
		1 1 0
		1 1 1
		0 1 1
		0 1 0];

	cube = cube * s;
	cube = cube - ones(length(cube),1) * (c + s/2);
 
	if nargout == 1,
		o1 = cube;
	elseif nargout == 3,
		o1 = cube(:,1);
		o2 = cube(:,2);
		o3 = cube(:,3);
	end
