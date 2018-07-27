%KCIRCLE 	Create circular structuring element
%
%	s = kcircle(r)
%	s = kcircle(r, w)
%
%	Return a square matrix of zeros with a central circular region of 
%	radius r of ones.  Matrix size is (2r+1) x (2r+1) or w*w.
%
%	If r is a 2-element vector then it returns an annulus of ones, and
%	the two numbers are interpretted as inner and outer radii.
%
% SEE ALSO: ones imorph
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%		pic 3/95
% $Header: /home/autom/pic/cvsroot/image-toolbox/kcircle.m,v 1.1 2005/10/23 11:29:29 pic Exp $
% $Log: kcircle.m,v $
% Revision 1.1  2005/10/23 11:29:29  pic
% Circle/annulus kernel.
%
% Revision 1.2  2002/05/26 11:00:47  pic
% Fix bug in annulus mode.
%
% Revision 1.1.1.1  2002/05/26 10:50:21  pic
% initial import
%

%
function s = kcircle(r, w)

	if ismatrix(r) 
		rmax = max(r(:));
		rmin = min(r(:));
	else
		rmax = r;
	end

	if nargin == 1,
	  w = 2*rmax+1;
	  c = rmax+1;
	else
	  c = ceil(w/2);
	end
	s = zeros(w,w);

	if ismatrix(r) 
		s = icircle(rmax,w) - icircle(rmin, w);
	else
		[x,y] = find(s == 0);
		x = x - c;
		y = y - c;
		l = find(sqrt(x.^2+y.^2) <= r);
		s(l) = ones(length(l),1);
	end
