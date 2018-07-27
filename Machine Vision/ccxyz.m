%CCXYZ	XYZ chromaticity coordinates
%
%	xyz = CCXYZ(lambda)
%		Compute xyz chromaticity coordinates for a 
%		specific wavelength.
%
%	xyz = CCXYZ(lambda, e)
%		Compute xyz chromaticity coordinates for a spectral
%		response e, where elements of e correspond to the wavelength
%		lambda.
%
% SEE ALSO: CMFXYZ
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%			  Peter Corke, 3/95, pic@brb.dmt.csiro.au
% $Header: /home/autom/pic/cvsroot/image-toolbox/ccxyz.m,v 1.1 2002/05/26 10:50:20 pic Exp $
% $Log: ccxyz.m,v $
% Revision 1.1  2002/05/26 10:50:20  pic
% Initial revision
%


function cc = ccxyz(lambda, e)
	xyz = cmfxyz(lambda);
	if nargin == 1,
		cc = xyz ./ (sum(xyz')'*ones(1,3));
	elseif nargin == 2,
		xyz = xyz .* (e*ones(1,3));
		xyz = sum(xyz);
		cc = xyz ./ (sum(xyz')'*ones(1,3));
	end
