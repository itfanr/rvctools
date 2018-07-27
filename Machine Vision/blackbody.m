%BLACKBODY	Compute blackbody emission spectrum
%
% 	E = BLACKBODY(lambda, T)
%
%	 Return blackbody radiation in (W/m^3) given lambda in (m) and 
%	temperature in (K).
%
%  	If lambda is a column vector, then E is a column vector whose 
%	elements correspond to to those in lambda.
%
%  	e.g.	l = [380:10:700]'*1e-9;	% visible spectrum
%	 	e = blackbody(l, 6500);	% solar spectrum
%	 	plot(l, e)
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%			  Peter Corke, 3/95

% $Header: /home/autom/pic/cvsroot/image-toolbox/blackbody.m,v 1.1 2002/05/26 10:50:19 pic Exp $
% $Log: blackbody.m,v $
% Revision 1.1  2002/05/26 10:50:19  pic
% Initial revision
%

function e = blackbody(lam, T)
	C1 = 5.9634e-17;
	C2 = 1.4387e-2;
	lam = lam(:);
	e = 2 * C1 ./ (lam.^5 .* (exp(C2/T./lam) - 1));
