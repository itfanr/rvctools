%CAMCALP	Camera calibration matrix from parameters
%
%	C = CAMCALP(cp)
%	C = CAMCALP(cp, Tcam)
%	C = CAMCALP(cp, pC, x, z)
%
%	Compute a 3x4 camera calibration matrix from given camera intrinsic
%	and extrinsic parameters.
%       CP is a camera parameter structure comprising:
%		cp.f          the focal length of the lens (m)
%        	cp.px, cp.py  horizontal and vertical pixel pitch of the 
%                             sensor (pixels/m)
%	 	cp.u0, cp.v0 principal point (u0, v0) in pixels,
%
%        Tcam is the pose of the camera wrt the world frame, defaults to
%		identity matrix if not given (optical axis along Z-axis).
%
%	Alternatively the camera pose can be given by specifying the coordinates
%	of the center, pC, and unit vectors for the camera's x-axis and 
%	z-axis (optical axis).
%
%	This camera model assumes that the focal point is at z=0 and the
%	image plane is at z=-f.  This means that the image is inverted on
%	the image plane.  Now in a real camera some of these inversions
%	are undone by the manner in which pixels are rasterized so that
%	generally increasing X in the world is increasing X on the image plane
%	and increasing Y in the world (down) is increasing Y on the image
%	plane.  This has to be handled by setting the sign on the pixel
%	scale factors.
%
%	The camera coordinate system is:
%
%		0------------------> X
%		|
%		|
%		|	+ (principal point)
%		|
%		|
%		v Y
%
%  	f, alphax and alphay are commonly known as the intrinsic camera 
%	parameters.  Tcam is commonly known as the extrinsic camera parameters.
%
% 
% SEE ALSO:  camcalp_c, camera, pulnix
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% $Header: /home/autom/pic/cvsroot/image-toolbox/camcalp.m,v 1.2 2005/10/20 11:24:11 pic Exp $
% $Log: camcalp.m,v $
% Revision 1.2  2005/10/20 11:24:11  pic
% Support camera parameter structure instead of vector.
%
% Revision 1.1.1.1  2002/05/26 10:50:19  pic
% initial import
%


function C = camcalp(cp, A, B, C)
	if nargin == 1,
		Tcam = eye(4);
	elseif nargin == 2,
		Tcam = A;
	elseif nargin == 4,
		pC = A(:);
		x = unit(B(:));
		z = unit(C(:));
		if abs(dot(x,z)) > 1e-10,
			error('x and z vectors should be orthogonal');
		end
		R=[x unit(cross(z,x)) z];

		Tcam = transl(pC) * [R zeros(3,1); 0 0 0 1];
	end

 	C = [	cp.px 0 cp.u0 0; 
		0 cp.py cp.v0 0;
		0 0 1 0
	    ] * [ 1 0 0 0;
		  0 1 0 0;
		  0 0 -1/cp.f 1;
		  0 0 0 1] * inv(Tcam);                    
