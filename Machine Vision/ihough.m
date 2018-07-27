%IHOUGH	Hough transform
%
%	params = IHOUGH
%	H = IHOUGH(IM)
%	H = IHOUGH(IM, params)
%
%	Compute the Hough transform of the image IM data.
%
%	The appropriate Hough accumulator cell is incremented by the
%	absolute value of the pixel value if it exceeds 
%	params.edgeThresh times the maximum value found.
%
%	Pixels within params.border of the edge will not increment.
%
% 	The accumulator array has theta across the columns and offset down 
%	the rows.  Theta spans the range -pi/2 to pi/2 in params.Nth increments.
%	Offset is in the range 1 to number of rows of IM with params.Nd steps.
%
%	Clipping is applied so that only those points lying within the Hough 
%	accumulator bounds are updated.
%
%	The output argument H is a structure that contains the accumulator
%	and the theta and offset value vectors for the accumulator columns 
%	and rows respectively.  With no output 
%	arguments the Hough accumulator is displayed as a greyscale image.
%
%	H.h	the Hough accumulator
%	H.theta	vector of theta values corresponding to H.h columns
%	H.d	vector of offset values corresponding to H.h rows
% 
%	For this version of the Hough transform lines are described by
%
%		d = y cos(theta) + x sin(theta)
%
%	where theta is the angle the line makes to horizontal axis, and d is 
%	the perpendicular distance between (0,0) and the line.  A horizontal 
%	line has theta = 0, a vertical line has theta = pi/2 or -pi/2
%
%	The parameter structure:
%
%	params.Nd number of offset steps (default 64)
%	params.Nth number of theta steps (default 64)
%	params.edgeThresh increment threshold (default 0.1)
%	params.border width of non-incrmenting border(default 8)
%
%
% SEE ALSO: xyhough testpattern isobel ilap
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% 1995 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/ihough.m,v 1.2 2005/10/23 11:16:18 pic Exp $
% $Log: ihough.m,v $
% Revision 1.2  2005/10/23 11:16:18  pic
% Supports param object argument.  Changes to suport new parameters.
%
% Revision 1.1.1.1  2002/05/26 10:50:22  pic
% initial import
%

function H = ihough(IM, params)

	% process arguments
	%  the param structure is common to ihough()
	if nargin < 2,
		default.Nd = 64;
		default.Nth = 64;
		default.edgeThresh = 0.10;
		default.border = 8;

		% for houghpeaks
		default.houghThresh = 0.40;
		default.radius = 5;
		default.interpWidth = 5;
	end
	if nargin == 0,
		H = default;
		return;
	elseif nargin == 1,
		params = default;
	end

	[nr,nc] = size(IM);

	% find the significant edge pixels
	IM = abs(IM);
	globalMax = max(IM(:));
	i = find(IM > (globalMax*params.edgeThresh));	
	[r,c]=ind2sub(size(IM), i);

	xyz = [c r IM(i)];

	% eliminate those near the edge
	k = (c < params.border) | (c>(nc-params.border)) | ...
		(r<params.border) | (r>(nr-params.border));
	xyz(k,:) = [];

	% now pass the x/y/strenth info to xyhough
	H = ihough_xy(xyz, [1 nr params.Nd], params.Nth);
