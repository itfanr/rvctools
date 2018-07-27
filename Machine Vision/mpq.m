%MPQ	Compute moments of polygon
%
% M = MPQ(iv, p, q)
%	compute the pq'th moment of the polygon whose vertices are iv.
%
%	Note that the points must be sorted such that they follow the 
%	perimeter in sequence (either clockwise or anti-clockwise).
%
% SEE ALSO: npq, upq, imoments
%
%	Copyright (c) Peter Corke, 1992  Machine Vision Toolbox for Matlab

% 1992 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/mpq.m,v 1.2 2005/10/23 11:47:30 pic Exp $
% $Log: mpq.m,v $
% Revision 1.2  2005/10/23 11:47:30  pic
% Updated doco and copyrights.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function m = mpq(iv, p, q)
	if ~all(iv(1,:) == iv(end,:))
		disp('closing the polygon')
		iv = [iv; iv(1,:)];
	end
	[n,nn] = size(iv);
	if nn < 2,
		error('must be at least two columns of data')
	end
	x = iv(:,1);
	y = iv(:,2);
	m = 0.0;
	for l=1:n
	    if l == 1
		dxl = x(l) - x(n);
		dyl = y(l) - y(n);
	    else
		dxl = x(l) - x(l-1);
		dyl = y(l) - y(l-1);
	    end
	    Al = x(l)*dyl - y(l)*dxl;
		
	    s = 0.0;
	    for i=0:p
		for j=0:q
			s = s + (-1)^(i+j) * combin(p,i) * combin(q,j)/(i+j+1) * x(l)^(p-i)*y(l)^(q-j) * dxl^i * dyl^j;
		end
	    end
	    m = m + Al * s;
	end
	m = m / (p+q+2);

function c = combin(n, r)
% 
% COMBIN(n,r)
%	compute number of combinations of size r from set n
%
	c = prod((n-r+1):n) / prod(1:r);
