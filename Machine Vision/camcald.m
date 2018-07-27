% CAMCALD	Compute camera calibration from data points
%
%	C = CAMCALD(D)
%	[C, E] = CAMCALD(D)
% 
%	Solve the camera calibration using a least squares technique.  Input is 
%	a table of data points, D, with each row of the form [x y z u v]
%	where (x,y,z) is the world coordinate, and (u,v) is the image 
%	plane coordinate.
%
%	Output is a 3x4 camera calibration matrix.  Optional return, E, is 
%	the maximum residual error after back substitution (unit of pixels). 
%
% SEE ALSO: CAMCALP, CAMERA, CAMCALT, INVCAMCAL
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

%	pic 4/91
% $Header: /home/autom/pic/cvsroot/image-toolbox/camcald.m,v 1.2 2005/10/20 11:23:47 pic Exp $
% $Log: camcald.m,v $
% Revision 1.2  2005/10/20 11:23:47  pic
% Minor doco change.
%
% Revision 1.1.1.1  2002/05/26 10:50:19  pic
% initial import
%



function [C, resid] = camcald(m)

	[rows,cols] = size(m);

%
% build the matrix as per Ballard and Brown p.482
%
% the row pair are one row at this point
%
	aa = [ m(:,1) m(:,2) m(:,3) ones(rows,1) zeros(rows,4)   ...
	       -m(:,4).*m(:,1) -m(:,4).*m(:,2) -m(:,4).*m(:,3)   ...
		zeros(rows,4) m(:,1) m(:,2) m(:,3) ones(rows,1)  ...
	       -m(:,5).*m(:,1) -m(:,5).*m(:,2) -m(:,5).*m(:,3)];
%
% reshape the matrix, so that the rows interleave
%
	aa = reshape(aa',11, rows*2)';

	bb = reshape( [m(:,4) m(:,5)]', 1, rows*2)';

	C = aa\bb;	% least squares solution
	resid = max(max(abs(aa * C - bb)));
	fprintf('maxm residual %f pixels.\n', resid);
	C = reshape([C;1]',4,3)';
