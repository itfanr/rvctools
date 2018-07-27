%PULNIX		Model for Pulnix camera and Digimax digitizer
%
%	PULNIX
%
%	Return a camera parameter structure for a camera and a digitizer.
%
% NOTE:
%	1. that the pixel scale factors are both negative which reflects
%	   how the camera electronics undo the image inversion caused by
%	   the lens.
%	2. all units are in metres.
%	3. parameters correspond to a Pulnix TN-6 camera, 8mm lens, and
%	   Datacube Digimax digitizer.  See "Visual Control of Robots",
%	   Corke, Research Studies Press, 1996.
%
% SEE ALSO:	camcalp
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% pic 7/96
% $Header: /home/autom/pic/cvsroot/image-toolbox/pulnix.m,v 1.2 2005/10/20 11:12:40 pic Exp $
% $Log: pulnix.m,v $
% Revision 1.2  2005/10/20 11:12:40  pic
% Use a parameter structure rather than vector.
%
% Revision 1.1.1.1  2002/05/26 10:50:24  pic
% initial import
%


function cp = pulnix
	
	cp.f = 7.8e-3;		% f
	cp.px = -79.2e3;		% alphax (pix/m)
	cp.py = -120.5e3;	% alphay (pix/m)
	cp.u0 = 274;		% u0
	cp.v0 = 210;		% v0
