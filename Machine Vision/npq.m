%NPQ	Compute central moments of polygon
%
% M = NPQ(iv, p, q)
%	compute the pq'th central moment of the polygon whose vertices are iv.
%
%	Note that the points must be sorted such that they follow the 
%	perimeter in sequence (either clockwise or anti-clockwise).
%
% SEE ALSO: mpq, upq, imoments
%
%	Copyright (c) Peter Corke, 1992  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/npq.m,v 1.2 2005/10/23 11:47:30 pic Exp $
% $Log: npq.m,v $
% Revision 1.2  2005/10/23 11:47:30  pic
% Updated doco and copyrights.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%

function m = npq(iv, p, q)

	if (p+q) < 2,
		error('normalized moments: p+q >= 2');
	end
	g = (p+q)/2 + 1;
	m = upq(iv, p, q) / mpq(iv, 0, 0)^g;
