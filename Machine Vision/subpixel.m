%SUBPIXEL  Subpixel interpolation of peak
%
%	[dxr, dyr] = subpixel(surf)
%	[dxr, dyr] = subpixel(surf, dx, dy)
%
%  Given a 2-d surface refine the estimate of the peak to subpixel precision/
%  The peak may be given by (dx, dy) or searched for.
%
% SEE ALSO: max2d, imatch, ihough
%
% Copyright (c) Peter Corke, 2001  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/subpixel.m,v 1.1 2005/10/23 11:30:11 pic Exp $
% $Log: subpixel.m,v $
% Revision 1.1  2005/10/23 11:30:11  pic
% Find peak to subpixel precision.
%

function [ddx,ddy] = subpixel(sim, dx, dy)
	[nr,nc] = size(sim);

	if nargin < 2,
		[dx, dy] = max2d(sim);
	end
	ddx = 0;
	ddy = 0;

	if dx > 1 & dy > 1 & dx < (nc-1) & dy < (nr-1),
		zn = sim(dy-1, dx);
		zs = sim(dy+1, dx);
		ze = sim(dy, dx+1);
		zw = sim(dy, dx-1);
		zc = sim(dy, dx);

		ddx = 0.5*(ze-zw)/(2*zc-zw-ze);
		ddy = 0.5*(zs-zn)/(2*zc-zn-zs);

		if abs(ddx) < 1 & abs(ddy) > 1,
			fprintf('interp too big %f %f\n', ddx, ddy);
			ddx = 0;
			ddy = 0;
		end
	end
