%HOMTRANS	transform points by homography
%
%	ph = homtrans(H, p)
%
% Apply the homography H to the image-plane points p.  p is an nx2 or
% nx3 matrix whose rows correspond to individual points.  Each row is of
% the form [u v w].  If w is not specified, ie. p has 2 columns, then it is
% assumed to be 1.
%
% Returns points as ph, an nx3 matrix where each row is the homogeneous
% point coordinates.
%
% Copyright (c) Peter Corke, 2002  Machine Vision Toolbox for Matlab


% $Header: /home/autom/pic/cvsroot/image-toolbox/homtrans.m,v 1.2 2005/10/23 11:33:30 pic Exp $
% $Log: homtrans.m,v $
% Revision 1.2  2005/10/23 11:33:30  pic
% Added copyright line.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%

function p2 = homtrans(H, p1)

	if numcols(p1) == 2,
		p1 = [p1 ones(numrows(p1),1)];
	end
	p = H*p1';

	p2 = p(1:2,:) ./ p([3 3],:);

	p2 = p2';
