%UPQ	Compute normalized central moments of polygon
%
% M = UPQ(iv, p, q)
%	compute the pq'th normalized central moment of the polygon 
%       whose vertices are iv.
%
%	Note that the points must be sorted such that they follow the 
%	perimeter in sequence (either clockwise or anti-clockwise).
%
% SEE ALSO: mpq, npq, imoments
%
%	Copyright (c) Peter Corke, 1992  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/upq.m,v 1.2 2005/10/23 11:47:30 pic Exp $
% $Log: upq.m,v $
% Revision 1.2  2005/10/23 11:47:30  pic
% Updated doco and copyrights.
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%

function m = upq(iv, p, q)

	m00 = mpq(iv, 0, 0);
	xc = mpq(iv, 1, 0) / m00;
	yc = mpq(iv, 0, 1) / m00;

	m = mpq(iv - ones(numrows(iv),1)*[xc yc], p, q);
