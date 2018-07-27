%RLUMINOS		Relative luminosity
%
%	R = RLUMINOS(lamda)
%
%	Return photopic luminosity (0..1) for wavelength specified.  
%	If lambda is a column vector then so is R.
%
% SEE ALSO:	cmfxyz
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/rluminos.m,v 1.1 2002/05/26 10:50:24 pic Exp $
% $Log: rluminos.m,v $
% Revision 1.1  2002/05/26 10:50:24  pic
% Initial revision
%

function lu = rluminos(lam)
	xyz = cmfxyz(lam);
	lu = xyz(:,2);	% photopic luminosity is the Y color matching function
