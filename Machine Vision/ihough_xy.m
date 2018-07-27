%IYHOUGH_XY	XY Hough transform
%
%	H = IHOUGH_XY(XYZ, drange, Nth)
%
%	Compute the Hough transform of the XY data given as the first two 
%	columns of XYZ.  The last column, if given, is the point strength, 
%	and is used as the increment for the Hough accumulator for that point.
%	If not give, all relevant cells are incremented by 1.
%
% 	The accumulator array has theta across the columns and offset down 
%	the rows.  Theta spans the range -pi/2 to pi/2 in Nth increments.
%	The distance span is given by drange which is either
%		[dmin dmax] in the range dmin to dmax in steps of 1, or
%		[dmin dmax Nd] in the range dmin to dmax with Nd steps.
%
%	Clipping is applied so that only those points lying within the Hough 
%	accumulator bounds are updated.
%
%	The output argument H is a structure that contains the accumulator
%	and the theta and offset value vectors for the accumulator columns 
%	and rows respectively.  With no output 
%	arguments the Hough accumulator is displayed as a greyscale image.
%
%	For this version of the Hough transform lines are described by
%
%		d = y cos(theta) + x sin(theta)
%
%	where theta is the angle the line makes to horizontal axis, and d is 
%	the perpendicular distance between (0,0) and the line.  A horizontal 
%	line has theta = 0, a vertical line has theta = pi/2 or -pi/2
%
% SEE ALSO: ihough mkline, mksq, isobel
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% 1995 Peter Corke
% $Header: /home/autom/pic/cvsroot/image-toolbox/ihough_xy.m,v 1.1 2005/10/23 11:31:29 pic Exp $
% $Log: ihough_xy.m,v $
% Revision 1.1  2005/10/23 11:31:29  pic
% Hough transform based on list of points (was xyhough.m)
%
% Revision 1.1.1.1  2002/05/26 10:50:25  pic
% initial import
%


function HH  = ihough_xy(XYZ, drange, Nth)

	dmin = drange(1);
	dmax = drange(2);
	dinc = 1;
	if length(drange) > 2,
		Nd = drange(3);
	else
		Nd = dmax - dmin + 1;
	end
	dinc = (dmax - dmin) / (Nd - 1);
	
	if numcols(XYZ) == 2,
		XYZ = [XYZ ones(numrows(XYZ),1)];
	end

	% compute the quantized theta values and the sin/cos
	th = [0:(Nth-1)]'/Nth*pi;
	%th = [0:(Nth-1)]'/Nth*pi-pi/2;
	st = sin(th);
	ct = cos(th);

	H = zeros(Nd, Nth);		% create the Hough accumulator

	% this is a fast `vectorized' algorithm

	% evaluate the index of the top of each column in the Hough array
	col0 = [0:(Nth-1)]'*Nd;

	for xyz = XYZ',
		x = xyz(1);		% determine (x, y) coordinate
		y = xyz(2);
		inc = xyz(3);
		d = round( ((y * ct + x * st)-dmin)/dinc );	% in the range 0 .. Nd-1

		% which elements are within the column
		inrange = (d>=0) & (d<Nd);

		di = d + col0 + 1;	% convert array of d values to Hough indices
		di = di(inrange);	% ignore those out of column range

		H(di) = H(di) + inc;	% increment the accumulator cells
	end

	dd = [0:(Nd-1)]'*dinc+dmin;

	% if no output arguments display the Hough accumulator
	if nargout == 0,
		image(th,dd,64*H/max(max(H)));
		xlabel('theta (rad)');
		ylabel('intercept');
		colormap(gray(64))
	end
	
	% return output arguments as specified

	if nargout >= 1,
		HH.h = H;
		HH.theta = th;
		HH.d = dd;
	end
