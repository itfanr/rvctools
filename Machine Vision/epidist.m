%EPIDIST calculate distance of points from epipolar line
%
%	d = epidist(F, pe, p)
%
% F is a fundamental matrix, pe is a Nx2 matrix representing N points for
% which epipolar lines are computed.  p is Mx2 and representes M points
% being tested for distance from each of the N epipolar lines.
%
% d is a NxM matrix, where the element (i,j) is the distance from the j'th
% point in p, to the i'th epipolar line, from pe.
%
% SEE ALSO:	epiline fmatrix
%
%	Copyright (c) Peter Corke, 2005  Machine Vision Toolbox for Matlab
% based on fmatrix code by
% Nuno Alexandre Cid Martins
% Coimbra, Oct 27, 1998
% I.S.R.


% Peter Corke 2005
% $Header: /home/autom/pic/cvsroot/image-toolbox/epidist.m,v 1.2 2005/10/23 11:08:57 pic Exp $
% $Log: epidist.m,v $
% Revision 1.2  2005/10/23 11:08:57  pic
% Added doco, optimized main loop.
%


% $Header: /home/autom/pic/cvsroot/image-toolbox/epidist.m,v 1.2 2005/10/23 11:08:57 pic Exp $
% $Log: epidist.m,v $
% Revision 1.2  2005/10/23 11:08:57  pic
% Added doco, optimized main loop.
%
% Revision 1.1.1.1  2002/05/26 10:50:20  pic
% initial import
%


function d = epidist(F, pe, p)

	for i=1:numrows(pe),
		l = F*[pe(i,:) 1]';
		for j=1:numrows(p),
			d(i,j) = (l(1,1)*p(j,1) + l(2,1)*p(j,2) + l(3,1)) ./ sqrt(l(1,1)^2 + l(2,1)^2);
		end
	end
