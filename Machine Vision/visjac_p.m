%VISJAC_P	Visual motion Jacobian
%
%	J = visjac_p(uv, z)
%	J = visjac_p(uv, z, f)
%	J = visjac_p(uv, z, cp)
%
%	Compute the visual Jacobian giving image-plane velocity in terms of
%	camera velocity.  C is a vector of camera intrinsic parameters
%
%		C = [f alphax alphay Cx Cy]
%
% REF:	A tutorial on Visual Servo Control, Hutchinson, Hager & Corke,
%	IEEE Trans. R&A, Vol 12(5), Oct, 1996, pp 651-670.
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/visjac_p.m,v 1.1 2005/10/30 03:26:11 pic Exp $
% $Log: visjac_p.m,v $
% Revision 1.1  2005/10/30 03:26:11  pic
% Image Jacobian for points
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%


function J = visjac_p(uv, z, cp)

	if nargin < 3,
		f = 1;
		ax = 1;
		ay = 1;
		u0 = 0;
		v0 = 0;
	else
		if isstruct(cp),
			f = cp.f;
			ax = cp.px;
			ay = cp.py;
			u0 = cp.u0;
			v0 = cp.v0;
		else
			f = cp;
			ax = 1;
			ay = 1;
			u0 = 0;
			v0 = 0;
		end
	end

	u = uv(1);
	v = uv(2);

	u = uv(1) - u0;
	v = uv(2) - v0;

	J = diag([ax ay]) * [ f/z 0 -u/z -u*v/f (f^2+u^2)/f -v
		0 f/z -v/z -(f^2+v^2)/f u*v/f u];
