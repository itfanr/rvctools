%KLAPLACE	Laplacian kernel
%
%	k = klaplace
%
%	Return the Laplacian kernel
%		0 -1  0
%		-1 4 -1
%		0 -1  0
%
% SEE ALSO:	ilaplace conv2
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/klaplace.m,v 1.1 2005/10/23 12:06:52 pic Exp $
% $Log: klaplace.m,v $
% Revision 1.1  2005/10/23 12:06:52  pic
% Common kernels.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%


function k = ilap;
	k = [0 -1 0; -1 4 -1; 0 -1 0];

